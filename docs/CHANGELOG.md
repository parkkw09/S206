# docs CHANGELOG

이 문서는 `docs/` 폴더 자체의 변경 이력을 추적합니다.
코드 변경 이력은 `git log` 를 참고하세요.

## 2026-04-22 — High 시리즈(H-1 ~ H-7) 전원 해결 & history 이관

- **코드/설정**
  - **H-5** API 키 분리 — `Config/Secrets.xcconfig` + `Config/Secrets.xcconfig.example` 신설, `.gitignore` 에 `Config/Secrets.xcconfig` 추가. `S206.xcodeproj/project.pbxproj` 의 App 타겟 Debug/Release 양쪽에 `baseConfigurationReference` 연결, `Config` 그룹 생성. `S206/Resources/Info.plist` 의 `SEOUL_KEY` 리터럴을 `$(SEOUL_KEY)` 치환 토큰으로 교체. 빌드 산출물(`S206.app/Info.plist`) 에서 실제 키가 치환되는 것을 `PlistBuddy` 로 확인.
  - **H-6** ATS 축소 — `Info.plist` 의 `NSAllowsArbitraryLoads` 제거, `NSExceptionDomains.openapi.seoul.go.kr`(`NSExceptionAllowsInsecureHTTPLoads=true`, `NSIncludesSubdomains=true`) 만 허용. 빌드 산출물에서 예외 구조 축소 확인.
  - **H-7** 배포 타겟 통일 — `IPHONEOS_DEPLOYMENT_TARGET` 6개 지점(프로젝트 Debug/Release, App Debug/Release, Tests Debug/Release)을 전부 **iOS 15.0** 으로 통일.
  - **L-7** 부수 해결 — H-5 Info.plist 편집 과정에서 빈 값이던 `LSApplicationCategoryType` 키를 함께 제거.
  - 검증: `xcodebuild -project S206.xcodeproj -scheme S206 -destination 'generic/platform=iOS Simulator' build-for-testing` → `** TEST BUILD SUCCEEDED **`.
- **이미 코드로 해결되어 있던 항목(문서 상태만 최종 반영)**
  - **H-1** 레이어 재배치: `SeoulRepository` → Domain, `SeoulError` 독립 파일, `SeoulMapper` / `NetworkConfig` 도입, `Domain/Translator/SeoulTranslator.swift` 삭제.
  - **H-2** `SeoulError` 케이스 재설계 (`network` / `decoding` / `server` / `missingConfiguration` / `unknown`) + `LocalizedError` 구현, 오타 제거.
  - **H-3** Repository / UseCase init 을 non-optional 로 교정 (`init(remote:)` / `init(repository:)`), 방어 코드 제거.
  - **H-4** 성공코드 상수화 (`SeoulMapper.successCode`) + 검증 로직을 UseCase → Mapper 로 이관.
- **문서**
  - `issues-resolved.md` — 인덱스 표에 H-1 ~ H-7 일곱 줄 추가, `🟠 High` 카테고리 섹션 신설하여 항목별 "원래 현상 + 해결 + 관련 파일" 보존.
  - `issues.md` — High 섹션 본문 제거, "전원 해결 → history 이관" 안내 + 1차/2차 라운드 구분 서술. L-7 도 `✅ RESOLVED` 로 임시 표기. 요약 표를 High 0건 상태로 재구성.
  - `TODO.md` — Phase 4 의 H-5/H-6/H-7/L-7 체크. H-5 는 README 키 절차 안내 / `git filter-repo` 잔여 과제만 남김.
  - `CHANGELOG.md` — 본 엔트리 추가.
- **잔여**: H-5 관련 (README 키 발급/교체 가이드 작성, git 히스토리에서 평문 키 제거), 그리고 Medium/Low 항목들.

## 2026-04-22 — 해결 이슈 히스토리 분리 (`issues-resolved.md` 신설)

- `docs/issues-resolved.md` 신규 작성. `issues.md` 에 남아 있던 Critical(C-1 ~ C-5) 의 "원래 현상 + 해결" 블록을 통째로 이관하고, 인덱스 표 + 카테고리 섹션 + 운영 규칙을 함께 배치.
- `docs/issues.md` 정리
  - Critical 섹션 본문 블록 제거, 해당 자리는 "전부 해결 → history 이관" 안내 한 줄 + `issues-resolved.md` 링크로 교체.
  - 헤더의 상태 표기 규칙을 "삭제하지 않고 `✅ RESOLVED` 로 전환" → "해결 시 `issues-resolved.md` 로 이관" 으로 갱신.
  - 카테고리 요약 표를 "미해결 항목 기준" 으로 재구성, Critical 은 모두 `— (history 참조)` 로 표시.
- 앞으로 해결되는 항목은 "`issues.md` 에서 제거 → `issues-resolved.md` 인덱스 + 섹션에 추가 → `CHANGELOG.md` 한 줄" 3단 운영 규칙에 따릅니다.

## 2026-04-22 — Critical 시리즈(C-1 ~ C-5) 전원 해결 & 문서 상태 전환

- **코드**: 크리티컬 이슈 5건이 모두 해결되었습니다 (해당 변경은 working tree 에 반영, 커밋 전).
  - **C-1** Composition Root — `S206/App/DI/AppContainer.swift` 추가. `NetworkConfig → SeoulRemoteDataSource → SeoulRepository → SeoulUsecase` 를 Swinject `.container` 스코프로 1회 구성. Storyboard VC 주입용 `inject(into:)` 제공. `AppDelegate` / `SceneDelegate` 가 이를 사용.
  - **C-2** `MainViewController` — `configure(usecase:)` setter 주입, `items: [NewCultureEvent]` 로 치환, `myData2` 제거, `viewDidAppear` 에서 `fetchCultureInfo()` 를 `Task` + `MainActor.run` 으로 호출, 로딩/에러 UI 최소 구성.
  - **C-3** `S206SeoulTests` 컴파일 복구 — init 라벨 교정(`init(remote:)` / `init(repository:)`) 후 테스트 파일 전면 재작성. `MockSeoulRemoteDataSource`, `StubRepository`, `makeSuccessResponse` 도입.
  - **C-4** 비동기 테스트 실질 검증 — 전 테스트를 `async throws` 로 전환, `XCTAssertEqual` / `XCTAssertThrowsError` / `do/catch` 패턴으로 결과를 단정.
  - **C-5** `SeoulApi.validate(statusCode:)` 를 `200..<300` 으로 축소. 200 범위 내 application-level 실패는 `SeoulMapper.toDomain` 이 `SeoulError.server(code:message:)` 로 변환.
  - 검증: `xcodebuild -project S206.xcodeproj -scheme S206 -destination 'generic/platform=iOS Simulator' build-for-testing` → `** TEST BUILD SUCCEEDED **`.
- **문서**
  - `issues.md` — C-1 ~ C-5 를 각각 `✅ RESOLVED (2026-04-22)` 로 전환하고, "원래 현상 + 해결" 쌍으로 기록 보존. 카테고리 요약 표에도 체크 표시 반영.
  - `TODO.md` — Phase 1 전원 체크, Phase 2 는 M-1(오타 rename) 만 남기고 나머지 체크, Phase 3 는 CI 항목만 남기고 체크.
  - `CHANGELOG.md` — 본 엔트리 추가.
- **남은 우선 과제**: H-5 (`SEOUL_KEY` 분리), H-6 (ATS 축소), H-7 (배포 타겟 통일), M-1 (`regisrationDate` rename), M-5 ~ M-7 (리소스 정리), Phase 3 의 CI.

## 2026-04-22 — 목표 설계(architecture.md) 기준 문서 재정렬

- `architecture.md` 가 목표 설계(`AppContainer`, `NetworkConfig`, `SeoulMapper`, 확장된 `SeoulError`, Storyboard + setter 주입 등) 를 기술하고 있음을 확인.
- 나머지 문서를 **현재 코드 스냅샷 ↔ 목표 설계 갭** 을 명확히 보여주도록 재작성:
  - `README.md` — "현재 vs 목표" 비교표 추가, Phase 로드맵 요약
  - `code-analysis.md` — 빌드 설정 섹션(배포 타겟 3중 불일치 포함), Localizable/Images/Colors 잔재, dead code 분석 추가. 말미에 목표 설계와의 차이 요약 표 추가.
  - `issues.md` — 이슈를 "C-* / H-* / M-* / L-*" ID 체계로 재정비. 각 항목에 *현재 코드* 와 *목표 설계* 를 나란히 표기.
  - `TODO.md` — Phase 1 (Composition Root) → 2 (레이어 재배치 & 에러 일원화) → 3 (테스트 복구) → 4 (보안/빌드) → 5 (리소스/기능) 로 재구성. 각 체크 항목에 이슈 ID 연결.
- 추가로 발견한 이슈:
  - `SeoulApi.validate(statusCode: 200..<500)` 가 4xx 를 성공 처리 (C-5)
  - 배포 타겟 App 13.0 / Project 14.5 / Tests 15.5 불일치 (H-7)
  - `Localizable.strings`, `Images.xcassets`, `Colors.xcassets` 가 이전 프로젝트의 잔재 (M-5 ~ M-7)
  - `MainViewController.myData` 는 dead code, `myData2` 만 렌더링 (C-2 에 포함)
  - `SeoulData.swift` 파일 헤더 주석이 `S206Local.swift` 로 불일치 (L-5)
  - `SceneDelegate.appDelegate` 프로퍼티 미사용 (L-6)
  - `Info.plist.LSApplicationCategoryType` 빈 값 (L-7)

## 2026-04-22 — 초기 분석 기록

- `docs/` 폴더 생성.
- 다음 문서를 작성:
  - `README.md` — 프로젝트 개요 및 문서 인덱스
  - `architecture.md` — Clean Architecture 레이어 구조와 의존성 흐름
  - `code-analysis.md` — 파일/타입별 상세 분석
  - `issues.md` — 우선순위별 이슈·개선점 목록
  - `TODO.md` — Phase 별 작업 계획
  - `CHANGELOG.md` — 본 문서
- 분석 대상 커밋: `1d976fd working` (HEAD)
- 주요 발견 사항:
  - Swinject DI 배선이 전부 주석 상태 → 앱이 실제 API 를 호출하지 않음.
  - `S206SeoulTests` 가 컴파일 실패 상태 (`SeoulRepositoryImpl(remote:)`, `getCultureInfo1/2` 접근).
  - `SEOUL_KEY` 가 `Info.plist` 에 평문 커밋됨.
  - `reponseFailure`, `regisrationDate` 등 오타가 여러 파일에 걸쳐 존재.
