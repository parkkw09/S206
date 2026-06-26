# 해결된 이슈 히스토리

[`issues.md`](./issues.md) 에서 `✅ RESOLVED` 상태가 된 항목을 이동 보관합니다.
항목 ID(`C-*` / `H-*` / `M-*` / `L-*`)는 안정적으로 유지되며, 삭제하지 않고 여기서 "원래 현상 + 해결 결과" 쌍으로 보존합니다.

> 최신 갱신: 2026-06-26
> 관련 코드 커밋/변경 상세는 `git log` 또는 [`CHANGELOG.md`](./CHANGELOG.md) 참조.

## 인덱스

| ID | 제목 | 해결일 | 라운드 |
| --- | --- | --- | --- |
| C-1 | Composition Root 가 존재하지 않음 | 2026-04-22 | Critical 일괄 해소 |
| C-2 | `MainViewController` 가 Storyboard + 주입 패턴을 지원하지 않음 | 2026-04-22 | Critical 일괄 해소 |
| C-3 | `S206SeoulTests` 컴파일 실패 | 2026-04-22 | Critical 일괄 해소 |
| C-4 | 비동기 테스트가 실제로 검증하지 않음 | 2026-04-22 | Critical 일괄 해소 |
| C-5 | `SeoulApi.validate(statusCode: 200..<500)` 가 4xx 도 성공 처리 | 2026-04-22 | Critical 일괄 해소 |
| H-1 | 레이어 배치가 목표와 다름 | 2026-04-22 | High 1차 라운드 |
| H-2 | `SeoulError` 케이스가 빈약하고 오타 포함 | 2026-04-22 | High 1차 라운드 |
| H-3 | Repository / UseCase 의 의존성이 옵셔널 | 2026-04-22 | High 1차 라운드 |
| H-4 | 성공 코드가 매직 스트링으로 하드코딩 | 2026-04-22 | High 1차 라운드 |
| H-5 | API 키가 리포지토리에 평문 저장 | 2026-04-22 | High 2차 라운드 |
| H-6 | `NSAllowsArbitraryLoads = true` | 2026-04-22 | High 2차 라운드 |
| H-7 | 배포 타겟(Deployment Target) 3중 불일치 | 2026-04-22 | High 2차 라운드 |
| M-1 | `regisrationDate` 오타 | 2026-06-26 | mos 기조 정렬 라운드 |
| M-3 | `SeoulApi` `getCultureEventInfo1/2` 중복 | 2026-06-26 | mos 기조 정렬 라운드 |
| M-4 | API 파라미터 하드코딩 (`startIndex=1, endIndex=5`) | 2026-06-26 | mos 기조 정렬 라운드 |

## 🔴 Critical

### C-1. Composition Root 가 존재하지 않음 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `AppDelegate` / `SceneDelegate` 양쪽 모두 DI 코드가 전부 주석. `MainViewController.seoulUsecase` 가 항상 nil 이라 API 호출 경로가 끊겨 있었음. 화면에 `["a", "b", "c"]` 더미만 표시됨.
- **해결**
  - `S206/App/DI/AppContainer.swift` 신규 작성. Swinject `Container` 를 소유하고 부팅 시 `NetworkConfig → SeoulRemoteDataSource → SeoulRepository → SeoulUsecase` 를 `.container` 스코프로 한 번에 등록.
  - Storyboard VC 용 `inject(into viewController: MainViewController)` 제공 → 내부에서 `SeoulUsecase` 를 resolve 해 `configure(usecase:)` 로 setter 주입.
  - `AppDelegate` 가 `let appContainer = AppContainer()` 로 단일 루트를 소유.
  - `SceneDelegate.scene(_:willConnectTo:options:)` 가 Storyboard 가 만든 root VC 또는 수동 경로 둘 다 커버하며 `appContainer.inject(into:)` 호출.
  - `SwinjectStoryboard` 같은 추가 의존은 도입하지 않음 (수동 주입 표준 패턴 유지).
- **관련 파일**: `S206/App/DI/AppContainer.swift`, `S206/App/AppDelegate.swift`, `S206/App/SceneDelegate.swift`

### C-2. `MainViewController` 가 Storyboard + 주입 패턴을 지원하지 않음 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `var seoulUsecase: SeoulUsecase?` 옵셔널, `myData` 는 dead code, `myData2 = ["a", "b", "c"]` 만 렌더링, `viewDidAppear` 호출부는 주석, `myLabel.text = "gdsg"` 자리 표시자.
- **해결**
  - `private var usecase: SeoulUsecase?` + `configure(usecase:)` setter 주입 진입점 추가 (`assert` 로 1회 호출 강제).
  - dead code `myData`, `myData2` 제거 → `private var items: [NewCultureEvent] = []` 로 치환.
  - `viewDidLoad` 에서 `myLabel.text = "Loading..."` + tableView 위임 설정, `viewDidAppear` 에서 `fetchCultureInfo()` 호출.
  - `fetchCultureInfo()` 는 `Task` + `MainActor.run` 으로 `usecase.getCultureInfo()` 결과를 적용하고, 에러 시 `myLabel` 에 에러 메시지를 표시.
- **관련 파일**: `S206/App/Presentation/View/Main/MainViewController.swift`

### C-3. `S206SeoulTests` 컴파일 실패 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `SeoulRepositoryImpl(remote: SeoulApi())` 로 호출하고 있으나 실제 init 레이블이 `init(_source:)` 였고, `repository?.getCultureInfo1()` / `getCultureInfo2()` 는 프로토콜에 정의되지 않아 테스트 타겟 빌드 자체가 실패.
- **해결**
  - Phase 2 에서 init 라벨을 `init(remote:)` / `init(repository:)` 로 교정(H-3 과 연계).
  - `S206Tests/S206SeoulTests.swift` 전체를 재작성: `MockSeoulRemoteDataSource`, `StubRepository`, `makeSuccessResponse` 픽스처를 도입해 `SeoulRepositoryImpl`, `SeoulUsecaseImpl`, `SeoulMapper` 를 각각 독립 테스트.
  - `xcodebuild -scheme S206 -destination 'generic/platform=iOS Simulator' build-for-testing` → **TEST BUILD SUCCEEDED** 확인.
- **관련 파일**: `S206Tests/S206SeoulTests.swift`

### C-4. 비동기 테스트가 실제로 검증하지 않음 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `testGetCultureInfoInRepository1/2`, `testGetCultureInfoInUsecase` 가 `Task { ... }` 안에서 `print` 만 호출 — `XCTAssert` / `XCTestExpectation` 없이 통과 여부와 결과가 무관.
- **해결**
  - 모든 테스트를 Swift 5.5+ `func testXxx() async throws` 스타일로 교체.
  - 성공 케이스: DTO → Domain 매핑, `count` / `code` 검증 + Mock 의 `callCount` / `lastStartIndex` / `lastEndIndex` 호출 파라미터 확인.
  - 실패 케이스: `do/catch let SeoulError.server(code, message)` 로 정확한 에러 타입을 검증.
  - Mapper 단위 테스트는 `XCTAssertThrowsError` 로 `SeoulError.server` 를 검증.
- **관련 파일**: `S206Tests/S206SeoulTests.swift`

### C-5. `SeoulApi.validate(statusCode: 200..<500)` 가 4xx 도 성공 처리 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: 4xx 응답이 성공 경로로 흘러 `serializingDecodable` 에서 빈 DTO 로 파싱 → 상위에서 `response.code = ""` 로 표시되어 원인 파악이 어려움.
- **해결**
  - `SeoulApi.getCultureInfo(startIndex:endIndex:)` 의 `validate(statusCode:)` 를 `200..<300` 으로 축소.
  - 200 범위 내에서 발생하는 application-level 실패(`CODE != INFO-000`) 는 `SeoulMapper.toDomain` 이 `SeoulError.server(code:message:)` 로 변환해 도메인에 그대로 전달.
  - `AFError` 는 `SeoulApi.mapToSeoulError` 에서 `decoding` / `network` / `unknown` 으로 1:1 매핑.
- **관련 파일**: `S206/App/Data/Source/Remote/SeoulApi.swift`, `S206/App/Data/Mapper/SeoulMapper.swift`

## 🟠 High

### H-1. 레이어 배치가 목표와 다름 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `SeoulRepository` 프로토콜이 Data 레이어에 있고, `SeoulError` 는 `SeoulApi.swift` 내부 enum, DTO→Domain 변환은 `Domain/Translator/SeoulTranslator`, 네트워크 설정은 `SeoulApi` 에 하드코딩 + `Bundle.main` 직접 접근으로 흩어져 있었음.
- **해결**
  - `SeoulRepository` 를 `S206/App/Domain/Repositories/SeoulRepository.swift` 로 이동 (Data → Domain, 의존성 역전 성립).
  - `SeoulError` 를 `S206/App/Domain/Errors/SeoulError.swift` 독립 파일로 분리 + `LocalizedError` 구현.
  - `Domain/Translator/SeoulTranslator.swift` 삭제, 대신 `S206/App/Data/Mapper/SeoulMapper.swift` 신규 작성해 DTO→Domain 매핑과 성공코드 검증을 함께 담당.
  - `S206/App/Data/Source/Remote/NetworkConfig.swift` 신규 작성해 `baseURL`/`apiKey`/`dataType`/`command` 를 구조체로 모으고 `fromBundle()` 팩토리 제공 → `SeoulApi` 는 `NetworkConfig` 를 주입받도록 변경.
  - `project.pbxproj` 파일 참조/그룹을 모두 새 경로로 정리.
- **관련 파일**: `S206/App/Domain/Repositories/SeoulRepository.swift`, `S206/App/Domain/Errors/SeoulError.swift`, `S206/App/Data/Mapper/SeoulMapper.swift`, `S206/App/Data/Source/Remote/NetworkConfig.swift`, `S206/App/Data/Source/Remote/SeoulApi.swift`, `S206.xcodeproj/project.pbxproj`

### H-2. `SeoulError` 케이스가 빈약하고 오타 포함 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `reponseFailure(message:)`, `requestFailure(message:)` 2개 뿐이고 `response` 오타까지 섞여 있어 에러 분기 정보가 부족했음.
- **해결**
  - 케이스를 다음 5개로 재설계: `network(message:)`, `decoding(message:)`, `server(code:, message:)`, `missingConfiguration(key:)`, `unknown(message:)`.
  - `Equatable` + `LocalizedError` 채택 → `errorDescription` 을 통해 Presentation 에서 사용자에게 표시 가능.
  - 호출처(`SeoulApi.mapToSeoulError`, `SeoulMapper.toDomain`, `NetworkConfig.fromBundle`) 모두 새 case 로 매핑. 오타 `reponseFailure` 는 제거.
- **관련 파일**: `S206/App/Domain/Errors/SeoulError.swift`, `S206/App/Data/Source/Remote/SeoulApi.swift`, `S206/App/Data/Source/Remote/NetworkConfig.swift`, `S206/App/Data/Mapper/SeoulMapper.swift`

### H-3. Repository / UseCase 의 의존성이 옵셔널 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `SeoulRepositoryImpl.init(_source:)` + `var source: SeoulDataSource? = nil`, `SeoulUsecaseImpl.init(repo: SeoulRepository?)` + 옵셔널 저장. 두 구현 모두 `source`/`repository` nil 체크와 `requestFailure` throw 분기가 포함되어 있었음.
- **해결**
  - `SeoulRepositoryImpl.init(remote: SeoulRemoteDataSource)` + `private let remote` non-optional.
  - `SeoulUsecaseImpl.init(repository: SeoulRepository)` + `private let repository` non-optional.
  - 내부 nil 체크·분기 전부 제거. initializer 라벨도 `remote:` / `repository:` 로 교정.
- **관련 파일**: `S206/App/Data/Repositories/Impl/SeoulRepositoryImpl.swift`, `S206/App/Domain/Usecases/Impl/SeoulUsecaseImpl.swift`

### H-4. 성공 코드가 매직 스트링으로 하드코딩 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `SeoulUsecaseImpl` 이 `"INFO-000"` 문자열을 그대로 비교.
- **해결**
  - `SeoulMapper.successCode = "INFO-000"` 상수로 이관.
  - 성공 코드 검증 자체도 UseCase → Mapper 로 책임 이전 (`toDomain` 내부에서 `result.code == successCode` 검사 후 실패 시 `SeoulError.server(...)` throw).
  - UseCase 는 Repository 호출만 담당하는 얇은 계층으로 축소.
- **관련 파일**: `S206/App/Data/Mapper/SeoulMapper.swift`, `S206/App/Domain/Usecases/Impl/SeoulUsecaseImpl.swift`

### H-5. API 키가 리포지토리에 평문 저장 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: `S206/Resources/Info.plist` 의 `SEOUL_KEY` 에 실제 API 키가 평문으로 들어 있어 공개 저장소에 그대로 노출 + git 히스토리에도 잔존.
- **해결**
  - `Config/Secrets.xcconfig` 신규 도입. `SEOUL_KEY = <발급받은 키>` 형태로 로컬에만 유지.
  - `Config/Secrets.xcconfig.example` 템플릿 커밋 (`SEOUL_KEY = YOUR_SEOUL_OPEN_DATA_API_KEY`) + 복사·치환 절차를 주석으로 명시.
  - `.gitignore` 에 `Config/Secrets.xcconfig` 추가 → 실제 키 파일은 커밋되지 않음.
  - `S206.xcodeproj/project.pbxproj` 의 App 타겟 Debug/Release 양쪽에 `baseConfigurationReference = Config/Secrets.xcconfig` 연결 + Config 그룹 생성.
  - `Info.plist` 의 `SEOUL_KEY` 값을 리터럴에서 `$(SEOUL_KEY)` 치환 토큰으로 교체 → 빌드 시 `INFOPLIST_EXPAND_BUILD_SETTINGS` 로 실제 키가 주입됨.
  - `NetworkConfig.fromBundle()` 은 그대로 `bundle.object(forInfoDictionaryKey: "SEOUL_KEY")` 를 읽어 `SeoulError.missingConfiguration(key:)` 로 방어.
  - 빌드 산출물 검증: `S206.app/Info.plist` 의 `SEOUL_KEY` 가 실제 키 값으로 치환되는 것을 `PlistBuddy -c "Print :SEOUL_KEY"` 로 확인.
- **잔여 과제 (별도 이슈화)**
  - 이미 git 히스토리에 존재하는 평문 키를 `git filter-repo` 등으로 정리하는 작업은 히스토리 재작성이 필요하므로 별도 라운드에서 처리 (README 에 절차 명시 예정).
  - CI 환경에서 비공개 시크릿 주입 방법(`xcodebuild -xcconfig $CI_SECRETS`) 은 Phase 3 의 CI 과제와 함께 설계.
- **관련 파일**: `Config/Secrets.xcconfig`, `Config/Secrets.xcconfig.example`, `.gitignore`, `S206/Resources/Info.plist`, `S206.xcodeproj/project.pbxproj`

### H-6. `NSAllowsArbitraryLoads = true` — ✅ RESOLVED (2026-04-22)
- **원래 현상**: 서울 OpenAPI 가 `http://openapi.seoul.go.kr:8088` 라는 이유로 `Info.plist` 에 전역 ATS 예외(`NSAllowsArbitraryLoads = true`) 가 열려 있었음 → 전체 HTTP 통신이 허용되는 과대 허용.
- **해결**
  - `Info.plist` 의 `NSAppTransportSecurity` 를 아래 형태로 축소.
    ```
    NSAppTransportSecurity
      └ NSExceptionDomains
          └ openapi.seoul.go.kr
              ├ NSExceptionAllowsInsecureHTTPLoads = true
              └ NSIncludesSubdomains = true
    ```
  - `NSAllowsArbitraryLoads` 키 자체를 제거. `openapi.seoul.go.kr` (하위 도메인 포함) 에 대해서만 HTTP 허용.
  - 빌드 산출물 검증: `PlistBuddy -c "Print :NSAppTransportSecurity"` 로 축소된 예외 구조 확인.
- **관련 파일**: `S206/Resources/Info.plist`

### H-7. 배포 타겟(Deployment Target) 3중 불일치 — ✅ RESOLVED (2026-04-22)
- **원래 현상**: App 타겟 = iOS 13.0 / 프로젝트 단 = iOS 14.5 / Tests 타겟 = iOS 15.5 로 서로 달라서 Swift concurrency 호환성 기준선이 애매하고 빌드/테스트 검증 범위가 각각 다름.
- **해결**
  - `S206.xcodeproj/project.pbxproj` 의 `IPHONEOS_DEPLOYMENT_TARGET` 6개 지점(프로젝트 Debug/Release, App Debug/Release, Tests Debug/Release)을 모두 **iOS 15.0** 으로 통일.
  - `async/await`, Swinject 등 현재 스택이 요구하는 최소치를 안정적으로 만족하면서 구형 단말 호환성도 확보.
  - 빌드 검증: `xcodebuild -project S206.xcodeproj -scheme S206 -destination 'generic/platform=iOS Simulator' build-for-testing` → `** TEST BUILD SUCCEEDED **`.
- **관련 파일**: `S206.xcodeproj/project.pbxproj`

---

## 운영 규칙

- 새로 해결되는 항목이 생기면
  1. `issues.md` 에서 해당 블록을 제거하고
  2. 본 문서의 **인덱스 표 + 카테고리 섹션** 양쪽에 "원래 현상 + 해결" 형태로 추가한 뒤
  3. [`CHANGELOG.md`](./CHANGELOG.md) 에 한 줄 요약을 남깁니다.
- 카테고리 섹션(🔴 Critical / 🟠 High / 🟡 Medium / 🟢 Low)은 필요해질 때 생성합니다.
- ID 는 재사용하지 않습니다. 삭제/중복 방지를 위해 이력은 항상 이 문서에 남깁니다.

---

## 🟡 Medium

### M-1. `regisrationDate` 오타 — ✅ RESOLVED (2026-06-26)
- **원래 현상**: `CulturalEvent.swift`(DTO), `NewCultureEvent.swift`(도메인), `SeoulMapper.swift` 3개 파일에 `regisrationDate` 오타가 잔재. JSON 키 `RGSTDATE` 와 매핑은 유지되고 있었으나 Swift 프로퍼티 이름이 잘못된 상태.
- **해결**: 세 파일 모두 `registrationDate` 로 rename. JSON `CodingKey` 는 `"RGSTDATE"` 로 유지.
- **관련 파일**: `S206/App/Data/Entities/CulturalEventInfo/CulturalEvent.swift`, `S206/App/Domain/Models/NewCultureEvent.swift`, `S206/App/Data/Mapper/SeoulMapper.swift`

### M-3. `SeoulApi` `getCultureEventInfo1/2` 중복 — ✅ RESOLVED (2026-06-26)
- **원래 현상**: 동일 로직에 Alamofire 결과 추출 방식만 다른 두 메서드가 공존.
- **해결**: `getCultureInfo(startIndex:endIndex:)` 단일 메서드로 통합. 이전 비교 예제 코드는 git 이력으로 보존.
- **관련 파일**: `S206/App/Data/Source/Remote/SeoulApi.swift`

### M-4. API 파라미터 하드코딩 — ✅ RESOLVED (2026-06-26)
- **원래 현상**: `startIndex = 1, endIndex = 5` 가 `SeoulApi` 내부 상수. 페이지네이션 불가능.
- **해결**: `SeoulUsecase`, `SeoulRepository`, `SeoulApi` 프로토콜/구현체 전 계층에서 `startIndex`/`endIndex` 를 파라미터로 승격. `MainViewModel` 에서 `PAGE_SIZE = 50` 으로 제어.
- **관련 파일**: `S206/App/Domain/Usecases/SeoulUsecase.swift`, `S206/App/Domain/Repositories/SeoulRepository.swift`, `S206/App/Data/Source/Remote/SeoulApi.swift`, `S206/App/Presentation/MainViewModel.swift`
