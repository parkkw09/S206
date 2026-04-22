# 코드 분석 (현재 스냅샷)

각 파일별 역할과 주요 로직을 **현재 구현된 그대로** 기록합니다. 경로는 `S206/App/...` 기준 (리소스는 `S206/Resources/...`).

> 목표 설계는 [`architecture.md`](./architecture.md) 를, 이 스냅샷과 목표 사이의 갭은 [`issues.md`](./issues.md) 를 참고하세요.

## 빌드 설정 (`S206.xcodeproj/project.pbxproj` 발췌)

| 항목 | 값 |
| --- | --- |
| Swift Version | 5.0 |
| App 번들 ID | `app.peter.S206` |
| Tests 번들 ID | `app.peter.S206Tests` |
| App Deployment Target | **iOS 13.0** |
| Tests Deployment Target | **iOS 15.5** ⚠️ (App 과 불일치) |
| 프로젝트 단 Deployment Target | iOS 14.5 (또 다른 값) |
| Marketing Version | 1.0 |
| SPM 의존성 | Alamofire, Swinject |

> ⚠️ 세 곳에 서로 다른 `IPHONEOS_DEPLOYMENT_TARGET` 이 흩어져 있음 → [issues.md H-5](./issues.md#h-5-배포-타겟deployment-target-불일치) 참고.

## App 엔트리

### `AppDelegate.swift`
- `@main` 진입점. `UIApplicationDelegate` 채택.
- 현재 `application(_:didFinishLaunchingWithOptions:)` 는 `return true` 만 수행.
- **주석 블록**: Swinject `Container` 생성 코드가 통째로 주석 처리되어 있음 (의도된 DI 설계).
- `Swinject` 를 import 만 하고 사용하지 않음.

### `SceneDelegate.swift`
- `UIWindowSceneDelegate` 채택.
- `scene(_:willConnectTo:options:)` 에서 `mainScene` 캐스팅만 수행하고, `window.rootViewController` 주입 코드는 주석.
- `let appDelegate = UIApplication.shared.delegate as! AppDelegate` 프로퍼티는 선언만 되어 있고 실제 사용 없음.
- Storyboard (`Main.storyboard`) 의 기본 초기 VC 가 그대로 사용됨.

## Data 레이어

### `Data/Entities/CulturalEventInfo/`
서울 OpenAPI `culturalEventInfo` 응답 구조에 대응하는 Codable 모델들.

| 타입 | 역할 | 주요 필드 |
| --- | --- | --- |
| `CulturalEventInfoResponse` | 최상위 래퍼 | `info: CulturalEventInfo` (`"culturalEventInfo"` 키) |
| `CulturalEventInfo` | 실제 데이터 블록 | `count (list_total_count)`, `result (RESULT)`, `list (row)` |
| `CulturalEventInfoResult` | 결과 코드 | `code (CODE)`, `message (MESSAGE)` |
| `CulturalEvent` | 개별 행사 1건 | 18개 필드 (title, place, startDate, endDate, mainImage, …) |

공통 패턴:
- 모든 타입이 파라미터 없는 `init()` 을 제공 → 네트워크 실패 시 빈 응답을 돌려주기 위함.
- `init(from:)` 에서 **모든 필드가 `try? decodeIfPresent ?? 기본값`** 으로 decoding 되어 있어 일부 필드 누락에도 크래시 없음. 대신 파싱 실패와 "빈 값" 을 구분하지 못한다는 트레이드오프가 있음.
- `CulturalEvent.regisrationDate` 는 **오타** (`registration` → `regisration`). JSON 키는 `RGSTDATE` 이므로 기능상 문제는 없지만 리팩터 시 정리 필요.

### `Data/Source/SeoulDataSource.swift`
```swift
protocol SeoulDataSource {
    func getCultureInfo() async throws -> CulturalEventInfoResponse
}
```
- Remote / Local 을 동일 인터페이스로 추상화.

### `Data/Source/Remote/SeoulApi.swift`
- `SeoulDataSource` 구현체. Alamofire 사용.
- 필드
  - `baseURL = http://openapi.seoul.go.kr:8088`
  - `dataType = json`, `command = culturalEventInfo`
- API 키는 `Bundle.main.object(forInfoDictionaryKey: "SEOUL_KEY")` 로 조회.
- `getCultureInfo()` → `getCultureEventInfo1(startIndex:1, endIndex:5)` 호출.
- `getCultureEventInfo1` / `getCultureEventInfo2` 는 기능이 동일 (Alamofire `.response` vs `.value` 로 결과를 꺼내는 방식 차이만 존재) → 비교 학습용.
- **주의**: `.validate(statusCode: 200..<500)` 으로 범위가 열려 있어 4xx 응답도 성공 경로로 빠짐 → [issues.md C-4](./issues.md#c-4-seoulapivalidatestatuscode-200500-가-4xx-도-성공으로-간주).
- `enum SeoulError { reponseFailure, requestFailure }` 선언 **(reponseFailure 오타)**.

### `Data/Source/Local/SeoulData.swift`
- `SeoulDataSource` 스텁. 내부 `response: [CulturalEventInfoResponse] = []` 을 가지고 있고, `getCultureInfo()` 는 그 first 또는 빈 응답을 반환.
- 초기값 세팅 수단이 없어 실질적으로는 **항상 빈 응답**.
- 파일 헤더 주석은 `S206Local.swift` 라고 되어 있어 실제 파일명과 불일치.

### `Data/Repositories/SeoulRepository.swift`
```swift
protocol SeoulRepository {
    func getCultureInfo() async throws -> CulturalEventInfoResponse
}
```

### `Data/Repositories/Impl/SeoulRepositoryImpl.swift`
- `init(_source: SeoulDataSource)` 로 주입.
- `getCultureInfo()` → 내부 `getCultureInfo1()` 을 호출.
- `getCultureInfo1()` (비프로토콜) : `try await source.getCultureInfo()`; source nil 이면 `requestFailure`.
- `getCultureInfo2()` (비프로토콜) : 동일하나 `try?` 로 옵셔널 바인딩 버전. 학습/비교용.

## Domain 레이어

### `Domain/Models/NewCultureEvent.swift`
- `CulturalEvent` 와 동일 필드를 가진 순수 도메인 모델 (Codable 아님, JSON 키 정보 제거).

### `Domain/Models/Response.swift`
- 제네릭 래퍼 `Response<T>`: `count, code, message, list`.

### `Domain/Translator/SeoulTranslator.swift`
- `static func getCultureEventInfo(response: CulturalEventInfoResponse) -> Response<NewCultureEvent>`
- `response.info` 에서 count/result 와 row 를 꺼내 `NewCultureEvent` 로 매핑.

### `Domain/Usecases/SeoulUsecase.swift`
```swift
protocol SeoulUsecase {
    func getCultureInfo() async throws -> Response<NewCultureEvent>
}
```

### `Domain/Usecases/Impl/SeoulUsecaseImpl.swift`
- `init(repo: SeoulRepository?)` 주입. (repository 를 옵셔널로 받는 것도 설계상 어색한 점.)
- repo.getCultureInfo → Translator → code 가 `INFO-000` 가 아니면 `reponseFailure` throw.
- `"INFO-000"` 이 매직 스트링으로 하드코딩됨.

## Presentation 레이어

### `Presentation/View/Main/MainViewController.swift`
- `UIViewController, UITableViewDelegate, UITableViewDataSource`.
- 프로퍼티:
  - `seoulUsecase: SeoulUsecase?` — 외부 주입 대상 (현재 항상 nil).
  - `myData: [NewCultureEvent]?` — **dead code**, 어느 TableView 메서드에서도 사용되지 않음.
  - `myData2 = ["a", "b", "c"]` — 현재 테이블이 실제로 사용하는 데이터.
- `@IBOutlet` : `myTableView: UITableView!`, `myLabel: UILabel!`.
- `viewDidLoad` : `myLabel.text = "gdsg"`, tableView delegate/dataSource 설정.
- `viewDidAppear` : `reloadData()` 만 수행, 주석된 Task 블록 안에 실제 usecase 호출 로직 존재.
- 테이블 cell reuse identifier : `"MyCell"` (Storyboard 의 prototype cell 과 일치).

### Storyboard

#### `Main.storyboard`
- Initial VC: `MainViewController` (`customClass="MainViewController"`, `customModule="S206"`).
- 서브뷰: `UILabel` (text="Label"), `UITableView` + 1개의 prototype cell (`reuseIdentifier="MyCell"`).
- `background = systemBackgroundColor` — 커스텀 컬러셋은 미사용.
- IBOutlet connections: `myLabel`, `myTableView`.

#### `LaunchScreen.storyboard`
- 기본 런치 스크린. 자세한 커스터마이즈 없음.

## Resources

### `Resources/Info.plist`
- `SEOUL_KEY = 7a4f58414a7061723736646a57694a` **(평문 커밋됨)**.
- `LSApplicationCategoryType = ""` (빈 문자열).
- `NSAppTransportSecurity.NSAllowsArbitraryLoads = true` — Seoul API 가 HTTP.
- `UISupportedInterfaceOrientations` : Portrait + Landscape.
- `UIRequiredDeviceCapabilities: [armv7]` (현재 시점 의미 없음 — iOS 11+ 은 64-bit 전용).
- 씬 설정: `UIWindowSceneSessionRoleApplication` → `SceneDelegate` + `UISceneStoryboardFile = Main`.

### `Resources/Localizable.strings` (en / ko)
- **현재 도메인과 전혀 무관한 "책" 관련 문자열**. 이전 프로젝트의 잔재로 보임.
- 키 목록: `app_name, new_book, detail_book, bookmark, ascending, descending, history, search, search_hint, add_bookmark, delete_bookmark`.
- 코드에서 `NSLocalizedString` / `String(localized:)` 호출 없음 → **어느 UI 에도 연결되지 않음**.

### `Resources/Images.xcassets`
- `app_icon.appiconset`
- `book, bookmark, history, information, search` 이미지셋 — 역시 이전 "북/검색" 앱용 자산.

### `Resources/Colors.xcassets`
- Pantone 2021 색상 팔레트: `illuminating(+500), purple_200/500/700, teal_200/700, ultimate_gray`
- Storyboard / 코드 어디에서도 참조되지 않음.

## 테스트

### `S206Tests/S206SeoulTests.swift`
- `setUpWithError()` 에서 `SeoulRepositoryImpl(remote: SeoulApi())` 호출.
  → **실제 init 은 `_source:` 라벨**이므로 **컴파일 실패**.
- `testGetCultureInfoInRepository1/2` 는 `repository?.getCultureInfo1() / getCultureInfo2()` 를 호출.
  → 이들은 `SeoulRepository` 프로토콜에 없는 메서드. 프로토콜 타입(`var repository: SeoulRepository?`)으로 선언돼 있어 **접근 불가 → 컴파일 실패**.
- 각 테스트가 `Task { ... }` 안에서 비동기 호출을 수행하지만 `await`/`expectation` 이 없어, **테스트가 실제로 결과를 검증하지 못함**.
- `XCTAssert` 류 사용 없음 → 실질적으로 no-op.

## 외부 의존성 (`S206.xcodeproj`)

- SPM 으로 `Alamofire`, `Swinject` 참조 (버전 핀 정보는 `Package.resolved` 에 기록됨).
- **Storyboard + DI 를 자연스럽게 연결하려면 `SwinjectStoryboard` 를 추가로 검토**해야 함 (현재는 참조 없음).

## 종합

- 레이어 분리와 프로토콜 추상화까지는 잘 되어 있으나, **"실제로 동작하는 경로"** 는 아직 만들어지지 않은 상태.
- 리소스(로컬라이즈/이미지/컬러)는 현 도메인과 불일치하는 잔재가 상당.
- 테스트 타겟은 컴파일 자체가 깨져 있어 CI 에 넣을 수 없음.

## 목표 설계와의 주요 차이

| 요소 | 현재 | 목표 |
| --- | --- | --- |
| DI | 없음 (주석) | `DI/AppContainer.swift` (Swinject) |
| `SeoulRepository` 위치 | Data | Domain/Repositories |
| `SeoulError` 위치 | `SeoulApi.swift` 내부 enum | `Domain/Errors/SeoulError.swift` |
| 에러 케이스 | 2개 (`reponseFailure`, `requestFailure`) | 5개 (`network / decoding / server / missingConfiguration / unknown`) |
| DTO→Domain 매퍼 | `Domain/Translator/SeoulTranslator` | `Data/Mapper/SeoulMapper` (성공코드 검증 포함) |
| 네트워크 설정 | `SeoulApi` + `Bundle.main` 직접 접근 | `NetworkConfig` 주입 |
| Repository init | `_source: SeoulDataSource` (옵셔널 저장) | `remote: SeoulRemoteDataSource` (비옵셔널 let) |
| UseCase init | `repo: SeoulRepository?` (옵셔널) | `repository: SeoulRepository` (비옵셔널 let) |
| VC 주입 | `var seoulUsecase: SeoulUsecase?` | `configure(usecase:)` setter |
| 성공코드 검증 | `SeoulUsecaseImpl` 이 `"INFO-000"` 하드코딩 | `SeoulMapper.successCode` 상수 |

자세한 이동 계획은 [`TODO.md`](./TODO.md) 의 Phase 2 참고.
