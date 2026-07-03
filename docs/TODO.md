# TODO — 향후 작업 계획

[issues.md](./issues.md) 의 각 항목을 실제 작업 단위로 묶은 체크리스트입니다.
각 Phase 가 끝날 때마다 [CHANGELOG.md](./CHANGELOG.md) 와 연동해 기록을 남깁니다.
괄호 안의 ID 는 이슈 번호 (C/H/M/L + 숫자) 입니다.

> 전반 원칙: **목표 설계([`architecture.md`](./architecture.md)) 에 맞춰가는 방향** 으로 작업합니다.
> 큰 리팩터링은 한 번에 끝내지 말고 Phase 단위 PR 로 쪼개기를 권장합니다.

## Phase 1 — Composition Root 구축 (앱을 실제로 돌게 만들기) ✅ 완료 (2026-04-22)

- [x] **(C-1)** `S206/App/DI/AppContainer.swift` 신규 작성
  - [x] Swinject `Container` 소유 및 부팅 시 1회 구성
  - [x] `NetworkConfig`, `SeoulRemoteDataSource`, `SeoulRepository`, `SeoulUsecase` 등록
  - [x] Storyboard VC 를 위한 `inject(into vc: MainViewController)` 메서드 추가
- [x] **(H-1 부분)** `Data/Source/Remote/NetworkConfig.swift` 신규 작성
  - [x] `baseURL`, `apiKey` 보관
  - [x] `static func fromBundle() throws -> NetworkConfig` 제공 (키 없으면 `SeoulError.missingConfiguration`)
- [x] **(C-1)** `AppDelegate` 에 `let appContainer = AppContainer()` 프로퍼티 추가
- [x] **(C-1)** `SceneDelegate.scene(_:willConnectTo:options:)` 에서
  - [x] Storyboard 가 만든 root `MainViewController` 참조
  - [x] `appContainer.inject(into:)` 로 주입
- [x] **(C-2)** `MainViewController`
  - [x] `configure(usecase: SeoulUsecase)` setter 추가
  - [x] `private var items: [NewCultureEvent] = []` (비옵셔널) 로 치환
  - [x] `myData2 = ["a", "b", "c"]` 제거
  - [x] `viewDidAppear` 의 주석된 Task 복구 + 로딩/에러 UI 최소 구성 (`Loading...` / `Error: ...` / `문화 행사 N건`)
  - [x] `myLabel.text = "gdsg"` → 의미 있는 문구로 교체 (`Localizable.strings` 키 적용은 M-5 과제로 보류)

### 완료 기준 — 달성
- `xcodebuild -scheme S206 build-for-testing` 통과 (`** TEST BUILD SUCCEEDED **`).
- 실제 빌드 산출물이 Storyboard rootVC 에 `SeoulUsecase` 를 주입하는 경로로 동작.
- 네트워크 에러 시 `myLabel` 에 에러 메시지가 표시됨 (Alert 승격은 Phase 5 에서 UX 작업 시 검토).

## Phase 2 — 레이어 재배치 & 에러 일원화 (대부분 완료)

- [x] **(H-1)** `SeoulRepository` 프로토콜 이동
  - `S206/App/Data/Repositories/SeoulRepository.swift` → `S206/App/Domain/Repositories/SeoulRepository.swift`
- [x] **(H-1)** `SeoulError` 분리
  - `SeoulApi.swift` 안의 enum 을 `S206/App/Domain/Errors/SeoulError.swift` 로 이동
- [x] **(H-2)** `SeoulError` 케이스 재설계
  - `network(message:)`, `decoding(message:)`, `server(code:String, message:String)`, `missingConfiguration(key:String)`, `unknown(message:)` 로 교체 (`LocalizedError` 도 함께 구현).
  - `reponseFailure` / `requestFailure` 오타는 제거되고 호출처 모두 새 case 로 매핑됨.
- [x] **(H-1, H-4)** `Data/Mapper/SeoulMapper.swift` 신규 작성
  - [x] `static let successCode = "INFO-000"` 상수
  - [x] `static func toDomain(_ dto:) throws -> Response<NewCultureEvent>` 에서 성공코드 검증 + 매핑 담당
  - [x] 기존 `Domain/Translator/SeoulTranslator.swift` 삭제
- [x] **(H-3)** Repository / UseCase init 정리
  - `SeoulRepositoryImpl.init(remote: SeoulRemoteDataSource)` + `let remote` (비옵셔널)
  - `SeoulUsecaseImpl.init(repository: SeoulRepository)` + `let repository` (비옵셔널)
  - 내부 nil 체크·분기 제거
- [x] **(C-5)** `SeoulApi` 의 `validate(statusCode:)` 를 `200..<300` 으로 축소
- [x] **(M-3)** `SeoulApi` 의 `getCultureEventInfo1/2` 중 하나로 통합 (`getCultureInfo(startIndex:endIndex:)` 단일 메서드로 정리)
- [x] **(M-4)** `startIndex`/`endIndex` 를 프로토콜/구현 파라미터로 승격 (페이지네이션 준비 완료)
- [ ] **(M-1)** `regisrationDate` → `registrationDate` rename (프로퍼티만, JSON 키 `RGSTDATE` 유지) — **미완료, Medium 우선순위로 이관**
- [x] `project.pbxproj` 의 파일 참조 경로 갱신 (이동·신규 파일 모두 반영, `generic/platform=iOS Simulator` 빌드 성공)

### 완료 기준 — 달성
- [`architecture.md`](./architecture.md) 의 폴더 구조·DI 등록 코드와 실제 코드가 일치.
- `SeoulError` 매칭으로 `MainViewController` 가 `error.localizedDescription` 을 통해 사용자에게 사유를 표시 가능.
- Presentation 레이어에서 유형별 분기(`catch let SeoulError.server(code, _) ...`) 가 준비됨. 실제 분기 UI 는 Phase 5 에서 확장.

## Phase 3 — 테스트 복구 & 기반 다지기 (핵심 완료)

- [x] **(C-3)** `S206SeoulTests` 컴파일 오류 수정 — `xcodebuild ... build-for-testing` 성공
- [x] **(C-4)** async 테스트로 전환 (`func testXxx() async throws`, `XCTAssertThrowsError`, `do/catch` 패턴 적용)
- [x] `MockSeoulRemoteDataSource` 도입 (Domain 의존 없이 DTO 반환, `callCount` / `lastStartIndex` / `lastEndIndex` 스파이)
  - 현재는 테스트 파일 내부 `private final class` 로 수용. 타 테스트에서 재사용 필요해지면 `S206Tests/Mocks/` 로 승격 고려.
- [x] Repository/UseCase 단위 테스트
  - [x] 성공 응답 → `Response<NewCultureEvent>` 매핑 검증 + 파라미터 전파 검증
  - [x] `CODE != INFO-000` → `SeoulError.server` throw 검증
  - [x] 네트워크 실패 → `SeoulError.network` 전파 검증
- [x] Mapper 단위 테스트 (`INFO-000` 및 실패 케이스)
- [ ] (선택) CI 설정 — GitHub Actions `xcodebuild test`

### 완료 기준 — 달성
- 모든 테스트가 실제로 통과/실패 여부를 판정 (Mock 기반).
- Mock 만으로 Network 없이 테스트가 컴파일되고 실행 가능한 상태.

## Phase 4 — 보안 / 빌드 설정 / 리포 위생 (High 부분 완료)

- [x] **(H-5)** API 키 분리 — `Config/Secrets.xcconfig` + `.example` + `.gitignore` + `Info.plist $(SEOUL_KEY)` 치환으로 완료
  - [x] `Config/Secrets.xcconfig` 도입 (실제 키 보관, `.gitignore` 처리)
  - [x] `Config/Secrets.xcconfig.example` 커밋 (템플릿)
  - [x] `S206.xcodeproj/project.pbxproj` 의 App 타겟 Debug/Release 에 `baseConfigurationReference` 연결
  - [x] `Info.plist` 의 `SEOUL_KEY` 값을 `$(SEOUL_KEY)` 치환 토큰으로 교체
  - [x] README 에 키 발급/교체 절차 명시 (2026-07-03)
  - [ ] (선택) `git filter-repo` 로 히스토리에서 기존 키 제거 (별도 라운드)
- [x] **(H-6)** ATS 예외 축소 — `NSAllowsArbitraryLoads` 제거, `NSExceptionDomains.openapi.seoul.go.kr` (NSIncludesSubdomains=true) 만 허용
- [x] **(H-7)** 배포 타겟 통일 — 프로젝트/App/Tests 6개 지점을 전부 **iOS 15.0** 으로 통일, `xcodebuild build-for-testing` 통과
- [x] **(L-7)** `Info.plist` 의 `LSApplicationCategoryType` 빈 값 키 제거 (H-5 작업 중 함께 정리)
- [x] **(L-2)** `UIRequiredDeviceCapabilities` 에서 `armv7` 제거 → `arm64` 로 교체 (2026-06-29)
- [x] **(L-3)** 기존 `.DS_Store` 트래킹 해제 — 트래킹 중인 파일 없음 확인 완료 (2026-07-03)
- [x] **(L-1)** 주석 처리된 구버전 코드 블록 제거 — 리팩토링 과정에서 제거됨 확인 완료 (2026-07-03)
- [x] **(L-5)** `SeoulData.swift` 의 파일 헤더 주석(`S206Local.swift`) 수정 — 이미 `SeoulData.swift` 파일은 삭제됨, 확인 완료 (2026-06-29)
- [x] **(L-6)** `SceneDelegate.appDelegate` — 별도 프로퍼티 아닌 지역 변수로 사용 중, 문제 없음 확인 (2026-06-29)

## Phase 5-A — mos 기조 정렬 (MVVM + 모델 완성) ✅ 완료 (2026-06-26)

안드로이드 대응 프로젝트(mos)의 아키텍처 기조를 iOS 쪽에 맞게 이식한 작업입니다.

- [x] **(M-1)** `regisrationDate` → `registrationDate` rename (CulturalEvent.swift, NewCultureEvent.swift, SeoulMapper.swift)
- [x] **(M-3)** `SeoulApi` `getCultureEventInfo1/2` → `getCultureInfo(startIndex:endIndex:)` 단일 메서드로 통합
- [x] **(M-4)** `startIndex`/`endIndex` 하드코딩 → 전 레이어 파라미터 승격
- [x] 도메인 모델 18필드 → **24필드 완성** (`inquiry`, `lot`, `lat`, `isFree`, `homepageAddr`, `proTime` 추가)
- [x] DTO `CulturalEvent` → `CulturalEventDTO` 리네임 (도메인 모델 `CulturalEvent` 와 이름 충돌 해소)
- [x] 도메인 모델 `NewCultureEvent` → `CulturalEvent` 리네임 (mos 와 동일 이름)
- [x] `Response<T>` → `CulturalEventPage(events:totalCount:)` 교체 — 서버 코드/메시지를 도메인 모델에서 제거
- [x] `SeoulUsecase` 프로토콜 → `callAsFunction(startIndex:endIndex:)` 패턴 (mos `operator fun invoke` 대응)
- [x] `LoadState` sealed enum 신규 작성 (`idle / loading / loadingMore / success / error(String)`)
- [x] `MainViewModel` 신규 작성 — Combine `@Published`, `PAGE_SIZE=50`, `initialize()` / `loadNextPage()` / `refresh()`
- [x] `MainViewController` → UseCase 직접 호출 제거, `MainViewModel` Combine 바인딩 + `willDisplay` 무한스크롤
- [x] `AppContainer` — `MainViewModel` 등록 및 `inject(into:)` 갱신
- [x] 테스트 전면 갱신 — `CulturalEventDTO`, `CulturalEventPage`, `callAsFunction` 기반으로 재작성
- [x] `xcodebuild build-for-testing` → `** TEST BUILD SUCCEEDED **`

### 완료 기준 — 달성
- mos 의 핵심 레이어 구조(ViewModel → UseCase → Repository)와 LoadState 상태 기계가 iOS 코드에 이식됨.
- 24필드 모델이 mos 와 완전히 일치.
- 페이지네이션 파이프라인(PAGE_SIZE=50) 이 동작 준비 상태.

## Phase 5-B — 리소스 정리 & 기능 확장

- [x] **(M-5)** `Localizable.strings` (en/ko) 재작성 및 소스 코드 연동 완료 (2026-07-03)
  - `app_name, event_list_title, loading, error_network, error_server, retry, …` 등 현 도메인 맞춤 키로 교체
- [ ] **(M-6)** `Images.xcassets` 정리 — 사용 안 하는 book/bookmark/history/… 에셋 제거 후 실제 필요 에셋 추가
- [ ] **(M-7)** `Colors.xcassets` 사용 여부 결정 (디자인 팔레트 확정 or 제거)
- [ ] **(M-2)** `SeoulData` (Local) 의 역할 결정 — 캐시 구현 or 삭제 (mos 는 Room + Remote-First Fallback)
- [x] **(L-4)** `Response<T>` 이름 구체화 → `CulturalEventPage` 로 해결됨 (Phase 5-A 에서 완료)
- [ ] 상세 화면 (행사 클릭 시 이미지/설명/링크)
- [ ] `mainImage` 로딩 (Kingfisher 등)
- [ ] 검색/필터 (자치구, 테마 코드)

## Phase 5-C — 코드리뷰 대응 (2026-06-29)

[`code-review-2026-06-26.md`](./code-review-2026-06-26.md) 의 지적사항을 반영한 작업입니다.

- [x] **(🔴#3)** `MainViewModel` 에 `@MainActor` 적용 — 컴파일러가 메인 스레드 접근을 보장, `MainActor.run` 래핑 전부 제거
- [x] **(🔴#5)** `refresh()` 의 진행 중 Task 미취소 경합 해결 — `currentTask` 프로퍼티 도입, `Task.isCancelled` 검사
- [x] **(🔴#1,#2)** 앱 실행 즉시 강제 OAuth 로그인 제거 — `startGoogleSignInIfNeeded()` 및 관련 코드 삭제
- [x] **(🟢 AppContainer)** `inject(into:)` 의 `self == nil` 무의미한 fallback 방어 코드 제거
- [x] **(🟡#8)** `GoogleApi.mapToGoogleError` — `responseValidationFailed` 를 statusCode 기반 세분화 (403/404 구분)
- [x] **(🟡#5-UI)** `refresh()` UI 연결 — `UIRefreshControl` 추가, Pull-to-Refresh 동작
- [x] **(🟢#10)** 파일명 ↔ 타입명 일치 — `NewCultureEvent.swift` → `CulturalEvent.swift`, `CulturalEvent.swift` → `CulturalEventDTO.swift`

### 완료 기준
- 코드리뷰 🔴 항목 3건 해결 (동시성 레이스, 강제 로그인, Task 경합)
- 코드리뷰 🟡 항목 2건 해결 (에러 매핑, Pull-to-Refresh)
- 코드리뷰 🟢 항목 2건 해결 (dead 방어 코드, 파일명 불일치)
- `xcodebuild build-for-testing` 통과 (Xcode 에서 확인 필요)

---

## 작업 가이드

- **PR 단위**: 가급적 Phase 단위 혹은 "이슈 ID 1~2개" 단위로 작게 자릅니다.
- **커밋 메시지 스타일**: 저장소 기존 히스토리(`create ...`, `update ...`, `add ...`) 와 일관성을 맞추되, 이슈 ID(예: `[C-1] setup AppContainer`) 를 덧붙이면 추적이 쉽습니다.
- **파일 이동**: Phase 2 에서 여러 파일을 이동하게 되므로 반드시 `S206.xcodeproj/project.pbxproj` 를 함께 갱신하세요.
- **체크박스 완료 시**: `- [x]` 로 체크 + [CHANGELOG.md](./CHANGELOG.md) 에 한 줄 추가.
