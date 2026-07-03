# S206 코드리뷰 (2026-06-26)

> 기존 문서를 참고하지 않고 소스 코드(36개 Swift 파일 + 설정)만 직접 읽어 작성한 독립 리뷰입니다.
> 5가지 관점: ① 아키텍처/레이어 경계 ② 동시성·상태관리 ③ 보안·인증 ④ 에러 처리·견고성 ⑤ 기능 완성도·죽은 코드·UX

심각도 표기: 🔴 높음 / 🟡 중간 / 🟢 낮음(개선 제안)

---

## ① 아키텍처 / 레이어 경계

전반적으로 Clean Architecture(Domain / Data / Presentation)가 깔끔하게 분리되어 있고, `AppContainer`가 유일한 Composition Root로서 구체 타입을 알고 나머지는 프로토콜만 의존하는 구조가 잘 지켜집니다. UseCase의 `callAsFunction`, Repository/DataSource 프로토콜 경계, Mapper 분리 모두 교과서적입니다. 이 항목은 대체로 양호합니다.

다만 아래는 짚어둘 만합니다.

- 🟡 **Domain 모델이 사실상 DTO의 복제본** — [NewCultureEvent.swift](../S206/App/Domain/Models/NewCultureEvent.swift)의 `CulturalEvent`는 24개 `String` 필드를 갖는데, [CulturalEvent.swift](../S206/App/Data/Entities/CulturalEventInfo/CulturalEvent.swift)의 `CulturalEventDTO`와 필드가 1:1로 완전히 동일합니다. [SeoulMapper.toDomain(_:)](../S206/App/Data/Mapper/SeoulMapper.swift#L27)은 순수 복사 보일러플레이트(24줄)입니다. 도메인이 실제로 구분되는 의미(타입 안전한 날짜, 좌표 `Double`, 유무료 `Bool`, 분류 enum 등)를 전혀 갖지 않아 레이어를 나눈 비용 대비 이득이 적습니다. 현 단계에선 수용 가능하나, 도메인 모델을 "정제된 표현"으로 키우거나(권장) 둘을 합치는 결정이 필요합니다.

- 🟢 **파일명과 타입명 불일치** — `NewCultureEvent.swift` 파일에 `CulturalEvent` 타입이 들어 있고, `CulturalEvent.swift` 파일에는 `CulturalEventDTO`가 들어 있습니다. 탐색 시 혼란을 줍니다. 파일명을 타입에 맞추는 것을 권장합니다.

- 🟢 **Presentation 모델 부재** — `MainViewModel`이 도메인 `CulturalEvent`를 그대로 View에 노출합니다. 앱 규모가 작아 현재는 문제없지만, 표시용 포맷팅(날짜 가공 등)이 늘면 View가 도메인에 직접 의존하는 결합이 부담이 됩니다.

---

## ② 동시성 / 상태관리

가장 손볼 곳이 많은 영역입니다.

- 🔴 **`MainViewModel`이 `@MainActor`가 아님 + 가변 상태 비보호** — [MainViewModel.swift](../S206/App/Presentation/MainViewModel.swift)는 `@Published` 프로퍼티와 `isLoading`, `nextStart`, `totalCount`를 갖지만 클래스에 `@MainActor` 표기가 없습니다. `loadNextPage()`는 호출 스레드에서 곧바로 `isLoading`/`loadState`를 읽고 쓰고([L42-45](../S206/App/Presentation/MainViewModel.swift#L42-L45)), 성공 콜백은 `MainActor.run` 안에서 다시 씁니다([L51-57](../S206/App/Presentation/MainViewModel.swift#L51-L57)). 즉 같은 가변 상태를 메인 가정 코드와 `MainActor.run` 블록이 섞어 접근합니다. 현재는 호출부가 메인에서만 들어와 우연히 동작하지만 컴파일러가 보장하지 않는 데이터 레이스입니다. **클래스 전체에 `@MainActor`를 붙이고 내부 `MainActor.run` 래핑을 제거**하면 `@Published`/UI 일관성과 경합 문제가 한 번에 해결됩니다.

- 🟡 **`refresh()`의 진행 중 Task와 경합** — [refresh()](../S206/App/Presentation/MainViewModel.swift#L67-L73)는 `isLoading = false`를 강제로 덮어쓴 뒤 `loadNextPage()`를 부릅니다. 직전 페이지 로딩 `Task`가 아직 살아 있으면, 그 Task의 완료 콜백이 뒤늦게 `events.append`/`nextStart += pageSize`를 실행해 새로 시작한 1페이지 로드와 섞일 수 있습니다. 진행 중 Task를 취소(`Task` 핸들 보관 + `cancel()`)하거나 세대(generation) 토큰으로 무효화해야 안전합니다.

- 🟡 **`onGoogleSignInStarted/Error`도 메인 가정** — [L77-91](../S206/App/Presentation/MainViewModel.swift#L77-L91)에서 `@Published googleAuthState`를 직접 변경합니다. 호출부인 [MainViewController.startGoogleSignInIfNeeded](../S206/App/Presentation/View/Main/MainViewController.swift#L98)가 `@MainActor` Task라 현재는 맞지만, 역시 `@MainActor`로 강제하는 편이 안전합니다.

- 🟢 **`GoogleAuthInterceptor.adapt`의 동기 토큰 읽기** — [TokenStore.currentToken](../S206/App/Data/Source/Local/TokenStore.swift#L28)은 `UserDefaults` 동기 읽기라 인터셉터에서 안전하지만, 저장 경로(`saveGoogleAccessToken`)가 `async`라 "저장 직후 다음 요청"의 가시성은 `UserDefaults`의 동기성에 의존합니다. 현재 구현상 문제는 없으나 Keychain 전환 시 이 가정이 깨질 수 있습니다.

---

## ③ 보안 / 인증

- 🔴 **OAuth Implicit Flow 사용** — [GoogleSignInManager.buildAuthorizationURL](../S206/App/Presentation/Auth/GoogleSignInManager.swift#L78)이 `response_type=token`(implicit flow)을 사용합니다. Google은 모바일 앱에 대해 implicit flow를 권장하지 않으며(보안상 deprecated 방향), access token이 리다이렉트 URL fragment로 노출됩니다. **PKCE 기반 Authorization Code Flow**가 표준 권장안입니다. 추가로 implicit flow에는 **refresh token이 없어** 토큰 만료 시 무조건 재로그인해야 합니다(④의 401 미복구와 연결됨).

- 🟡 **Access Token을 UserDefaults 평문 저장** — [UserDefaultsTokenStore](../S206/App/Data/Source/Local/TokenStore.swift#L20). 코드 주석도 인정하듯 Keychain 승격이 필요합니다. 탈옥/백업 노출 위험이 있는 자격증명입니다.

- 🟡 **세션 쿠키 비격리** — [prefersEphemeralWebBrowserSession = false](../S206/App/Presentation/Auth/GoogleSignInManager.swift#L59). 이전 사용자의 Google 세션이 남아 다른 계정으로 의도치 않게 로그인될 수 있습니다. 계정 전환 UX를 고려한다면 `true` 또는 명시적 prompt가 안전합니다.

- 🟢 **Secrets 관리 양호** — `Config/Secrets.xcconfig`는 gitignore 처리되어 있고 `.example`만 추적됩니다(확인함). `Info.plist`는 `$(GOOGLE_CLIENT_ID)`/`$(SEOUL_KEY)` 빌드 변수로 주입합니다. 좋습니다.

- 🟢 **ATS HTTP 예외** — `openapi.seoul.go.kr`에 평문 HTTP 예외를 둡니다. 서울시 OpenAPI가 8088 평문 포트라 불가피하지만, 도메인 한정 예외로 좁혀둔 점은 적절합니다.

---

## ④ 에러 처리 / 견고성

- 🟡 **모든 DTO가 "절대 실패하지 않는" 디코딩** — 모든 Codable 타입이 `init(from:)`에서 `(try? c.decodeIfPresent(...)) ?? 기본값` 패턴을 씁니다([YoutubeDTO.swift](../S206/App/Data/Entities/Youtube/YoutubeDTO.swift), [CulturalEvent.swift](../S206/App/Data/Entities/CulturalEventInfo/CulturalEvent.swift) 등). 부분 손상 응답에 견고하다는 장점이 있지만, **서버 스키마 변경/오타/잘못된 응답이 빈 값으로 조용히 흡수**되어 디버깅이 어렵습니다. 특히 [YoutubeResponse](../S206/App/Data/Entities/Youtube/YoutubeDTO.swift#L23-L29)는 `items`를 빈 배열로 fallback하므로 실제로는 오류 응답인데도 "구독 0개 성공"처럼 보입니다. `SeoulError.decoding`/`GoogleError.decoding`이 정의돼 있지만 이 전략 때문에 사실상 영원히 발생하지 않습니다. 적어도 최상위 컨테이너(또는 핵심 식별 필드)에 대해서는 디코딩 실패를 표면화하는 것을 권장합니다.

- 🟡 **`responseValidationFailed`를 network로 매핑** — [GoogleApi.mapToGoogleError](../S206/App/Data/Source/Remote/GoogleApi.swift#L90-L91)는 contentType/statusCode 검증 실패를 `.network`로 분류합니다. 403(쿼터 초과·권한 부족), 404 등 명백한 서버 측 응답이 "네트워크 오류"로 표시되어 사용자/로그가 원인을 오인합니다. statusCode 기반으로 401 외에 403/404도 분기하는 것이 좋습니다.

- 🟡 **401 발생 시 자동 복구 없음** — [statusCode == 401 → .unauthorized](../S206/App/Data/Source/Remote/GoogleApi.swift#L83)만 던질 뿐, 토큰 삭제/재로그인 유도/`googleAuthState` 갱신으로 이어지는 경로가 없습니다(애초에 YouTube 호출 자체가 미연결 — ⑤ 참고). refresh token이 없는 implicit flow라 만료 시 사용자가 막힙니다.

- 🟢 **Seoul 성공코드 검증 위치 적절** — [SeoulMapper](../S206/App/Data/Mapper/SeoulMapper.swift#L17)에서 `INFO-000`을 확인해 비즈니스 실패를 `SeoulError.server`로 변환하는 흐름은 좋습니다. 이게 Seoul 경로의 유일한 실질 방어선입니다.

---

## ⑤ 기능 완성도 / 죽은 코드 / UX

- 🔴 **YouTube 데이터 조회 기능이 통째로 미연결(죽은 코드)** — `GetSubscriptionsUseCase`, `GetPlaylistUseCase`, `GetContentDetailUseCase`와 그 구현, [GoogleApi](../S206/App/Data/Source/Remote/GoogleApi.swift)의 3개 호출, [GoogleRepositoryImpl](../S206/App/Data/Repositories/Impl/GoogleRepositoryImpl.swift)의 fetch 메서드가 모두 [AppContainer](../S206/App/DI/AppContainer.swift#L95-L103)에 등록만 되어 있고 **어디서도 호출되지 않습니다**. `MainViewModel`이 실제 사용하는 Google 의존성은 `save/clearGoogleTokenUseCase`뿐입니다([MainViewModel.swift L22-23](../S206/App/Presentation/MainViewModel.swift#L22-L23)). 즉 현재 앱은 "Google 로그인해서 토큰만 저장"하고 그 토큰으로 아무것도 하지 않습니다. 기능 미완성이거나, 인프라만 이식하고 화면을 안 만든 상태입니다.

- 🔴 **앱 실행 즉시 강제 OAuth 로그인 (UX)** — [viewDidAppear → startGoogleSignIfNeeded](../S206/App/Presentation/View/Main/MainViewController.swift#L43-L47)가 사용자 액션 없이 앱을 켜자마자 Google 로그인 웹뷰를 띄웁니다. "로그인" 버튼도, "로그아웃" 진입점도 없습니다(`signOut()`은 정의만 됨, 호출처 없음). 문화행사 목록만 보려는 사용자에게 즉시 OAuth 동의 화면이 뜨는 것은 강한 이탈 요인입니다. 명시적 버튼으로 전환해야 합니다.

- 🟡 **인증 상태가 `print`로만 처리** — [googleAuthState 구독부](../S206/App/Presentation/View/Main/MainViewController.swift#L68-L81)가 성공/실패를 콘솔 `print`만 합니다. 사용자에게 피드백이 없습니다(원본 안드로이드의 Toast 대응이 누락).

- 🟡 **`refresh()`가 UI에 미연결** — 페이지네이션 무한스크롤은 [willDisplay](../S206/App/Presentation/View/Main/MainViewController.swift#L135-L140)로 동작하지만, pull-to-refresh 등 [refresh()](../S206/App/Presentation/MainViewModel.swift#L67) 호출 경로가 없습니다. 초기 로드 실패 시 재시도 수단이 없습니다.

- 🟡 **테스트가 Seoul 경로에만 집중** — [S206SeoulTests.swift](../S206Tests/S206SeoulTests.swift)는 Repository/UseCase/Mapper(Seoul)를 잘 커버합니다. 그러나 **`MainViewModel`의 페이지네이션 상태 전이 로직(가장 버그 가능성 높은 부분), Google Repository/Mapper, OAuth 토큰 추출(`extractAccessToken`)에 대한 테스트가 전무**합니다. 비즈니스 위험이 큰 곳이 테스트되지 않았습니다.

- 🟢 **`AppContainer.inject`의 무의미한 fallback** — [self == nil 가드](../S206/App/DI/AppContainer.swift#L131-L137)에서 빈 `clientId`/`scope`로 `GoogleSignInManager`를 생성합니다. `AppContainer`는 `AppDelegate`가 강하게 보유하므로 이 시점 `self`가 nil일 일이 없고, 설령 그래도 빈 config의 매니저는 즉시 `missingConfiguration`을 던질 뿐입니다. 죽은 방어 코드입니다.

- 🟢 **셀 구성이 미완** — [cellForRowAt](../S206/App/Presentation/View/Main/MainViewController.swift#L129-L133)이 기본 `textLabel`에 `title`만 표시합니다(24개 필드 중 1개). 기능 자체가 아직 골격 단계임을 보여줍니다.

---

## 우선순위 요약

| # | 항목 | 심각도 | 영역 |
|---|------|--------|------|
| 1 | YouTube 조회 기능 전체 미연결(죽은 코드) | 🔴 | ⑤ |
| 2 | 실행 즉시 강제 OAuth 로그인 + 로그인/로그아웃 버튼 부재 | 🔴 | ⑤ |
| 3 | `MainViewModel` `@MainActor` 미적용 → 가변 상태 레이스 | 🔴 | ② |
| 4 | OAuth Implicit Flow (PKCE Code Flow 권장) | 🔴 | ③ |
| 5 | `refresh()`의 진행중 Task 미취소 경합 | 🟡 | ② |
| 6 | 디코딩이 절대 실패하지 않아 오류가 빈 값으로 흡수 | 🟡 | ④ |
| 7 | 토큰 평문(UserDefaults) 저장 → Keychain | 🟡 | ③ |
| 8 | 403/404가 network 오류로 오분류 + 401 미복구 | 🟡 | ④ |
| 9 | ViewModel·Google·OAuth 테스트 공백 | 🟡 | ⑤ |
| 10 | 도메인 모델이 DTO 복제본 / 파일·타입명 불일치 | 🟢 | ① |

### 가장 먼저 권할 3가지
1. `MainViewModel`에 `@MainActor`를 붙이고 내부 `MainActor.run` 래핑 제거 — 적은 변경으로 동시성 안정성 확보(#3).
2. 자동 로그인 제거 + 명시적 로그인/로그아웃 버튼 도입, 그리고 등록만 된 YouTube UseCase를 실제 화면에 연결하거나(기능 완성) 미사용이면 제거(#1, #2).
3. `MainViewModel` 페이지네이션 상태 전이 테스트 추가 — 위험 대비 커버리지가 가장 비어 있는 곳(#9).
