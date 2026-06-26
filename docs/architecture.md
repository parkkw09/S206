# 아키텍처

S206 은 **Clean Architecture + MVVM** 구조를 따르며, DI 는 **Swinject 기반 단일 Composition Root** 로 구성됩니다.
안드로이드 대응 프로젝트 mos(Hilt + Compose + MVVM)의 아키텍처 기조를 iOS(UIKit + Combine)로 이식한 설계입니다.

## 폴더 구조

```
S206/App
├── Data                        # 외부 세계와 맞닿은 레이어
│   ├── Entities                # 서버 JSON 과 1:1 매핑되는 Codable DTO (24필드)
│   │   └── CulturalEventInfo/
│   │       ├── CulturalEvent.swift          # struct CulturalEventDTO (DTO, 24필드)
│   │       ├── CulturalEventInfo.swift
│   │       ├── CulturalEventInfoResponse.swift
│   │       └── CulturalEventInfoResult.swift
│   ├── Mapper
│   │   └── SeoulMapper.swift               # CulturalEventDTO → CulturalEvent 변환 + 성공코드 검증
│   ├── Repositories
│   │   └── Impl/SeoulRepositoryImpl.swift  # Remote 호출 + Mapper 위임
│   └── Source
│       ├── SeoulDataSource.swift           # SeoulRemoteDataSource protocol
│       └── Remote/
│           ├── NetworkConfig.swift         # baseURL / apiKey 주입용
│           └── SeoulApi.swift              # Alamofire 기반 구현
├── Domain                      # 앱 비즈니스 규칙, 외부 의존성 0
│   ├── Errors
│   │   └── SeoulError.swift                # 도메인 공용 에러
│   ├── Models
│   │   ├── NewCultureEvent.swift           # struct CulturalEvent (도메인 모델, 24필드)
│   │   └── Response.swift                  # struct CulturalEventPage (events + totalCount)
│   ├── Repositories
│   │   └── SeoulRepository.swift           # 도메인이 정의하는 Repository 계약
│   └── Usecases
│       ├── SeoulUsecase.swift              # callAsFunction(startIndex:endIndex:) 프로토콜
│       └── Impl/SeoulUsecaseImpl.swift     # Repository 위임 구현체
├── DI
│   └── AppContainer.swift                  # Composition Root (Swinject)
├── Presentation                # UIKit + Combine
│   ├── LoadState.swift                     # enum LoadState (idle/loading/loadingMore/success/error)
│   ├── MainViewModel.swift                 # ObservableObject, PAGE_SIZE=50, 페이지네이션
│   └── View/
│       ├── LaunchScreen/LaunchScreen.storyboard
│       └── Main/
│           ├── Main.storyboard
│           └── MainViewController.swift    # Combine 바인딩, 무한스크롤
├── AppDelegate.swift                       # AppContainer 소유
└── SceneDelegate.swift                     # Storyboard rootVC 에 주입
```

## 의존성 흐름

```
MainViewController (Presentation)
      │ observes (@Published via Combine)
      ▼
MainViewModel (Presentation)
      │ calls callAsFunction(startIndex:endIndex:)
      ▼
SeoulUsecase (Domain protocol)  ──►  SeoulUsecaseImpl (Domain)
                                          │ uses
                                          ▼
                                  SeoulRepository (Domain protocol)  ──►  SeoulRepositoryImpl (Data)
                                                                                │
                                                              ┌─────────────────┼───────────────┐
                                                              ▼                 ▼
                                                SeoulRemoteDataSource (Data protocol)   SeoulMapper (Data)
                                                              │
                                                              ▼
                                                        SeoulApi (Remote, Alamofire)
                                                              │ uses
                                                              ▼
                                                     NetworkConfig (baseURL/apiKey)
```

- **모든 의존성은 안쪽(Domain) 으로만 향합니다.** Domain 은 Alamofire / UIKit / DTO 를 일절 모르며, 서버 응답 코드(`INFO-000`) 도 `SeoulMapper`(Data) 내부에 갇혀 있습니다.
- 각 레이어 경계는 프로토콜로만 통신하며, 구현체 이름(`...Impl`, `SeoulApi`) 은 Composition Root 인 `AppContainer` 에서만 등장합니다.
- `MainViewController` 는 `MainViewModel` 만 알고, `SeoulUsecase` 를 직접 참조하지 않습니다.

## 데이터 흐름 (정상 경로)

```
[MainViewController.viewDidAppear]
    → viewModel.initialize()
        → viewModel.loadNextPage()                        // LoadState: .idle → .loading
            → usecase(startIndex: 1, endIndex: 50)        // callAsFunction, async throws
                → repository.getCultureInfo(startIndex:endIndex:)
                    → remote.getCultureInfo(startIndex:endIndex:) // SeoulApi
                        → AF.request(...)                 // Alamofire
                        → serializingDecodable(CulturalEventInfoResponse.self)
                ← CulturalEventInfoResponse (DTO)
                ↓
            SeoulMapper.toDomain(dto)                     // 성공코드 검증 + CulturalEventDTO → CulturalEvent
                ↓ (throws SeoulError.server on bad code)
            CulturalEventPage(events:totalCount:)
        ↓
    @Published events += page.events                      // Combine sink → tableView.reloadData()
    @Published loadState = .success                       // Combine sink → myLabel 갱신
    nextStart += 50                                       // 다음 페이지 준비

[tableView willDisplay cell forRowAt — 마지막 10행 진입 시]
    → viewModel.loadNextPage()                            // LoadState: .success → .loadingMore → .success
```

## 에러 흐름

- 네트워크 실패 → `SeoulApi` 가 `AFError` 를 `SeoulError.network / .decoding / .unknown` 으로 매핑
- API 키 없음 → `NetworkConfig.fromBundle()` 이 `SeoulError.missingConfiguration(key:)` 던짐 (`AppContainer` 에서 `fatalError` 로 변환)
- 서버 실패 코드 → `SeoulMapper.toDomain` 이 `SeoulError.server(code:message:)` 던짐
- 모든 에러는 `SeoulError` 로 통일되어 Presentation 까지 올라감

## 외부 API

- Base URL: `http://openapi.seoul.go.kr:8088`
- 경로: `/{KEY}/json/culturalEventInfo/{START}/{END}/`
- API 키: `Info.plist` 의 `SEOUL_KEY` (→ `NetworkConfig` 가 읽어 주입)
- 성공 코드: `INFO-000` (`SeoulMapper.successCode`)

## DI (동작 중)

`AppContainer` 가 `container: Container` 를 소유하고 부팅 시 한 번만 구성:

```swift
container.register(NetworkConfig.self)        { _ in try! NetworkConfig.fromBundle() }.inObjectScope(.container)
container.register(SeoulRemoteDataSource.self){ r in SeoulApi(config: r.resolve(NetworkConfig.self)!) }.inObjectScope(.container)
container.register(SeoulRepository.self)      { r in SeoulRepositoryImpl(remote: r.resolve(SeoulRemoteDataSource.self)!) }.inObjectScope(.container)
container.register(SeoulUsecase.self)         { r in SeoulUsecaseImpl(repository: r.resolve(SeoulRepository.self)!) }.inObjectScope(.container)
container.register(MainViewModel.self)        { r in MainViewModel(usecase: r.resolve(SeoulUsecase.self)!) }.inObjectScope(.container)
```

Storyboard 로 생성된 `MainViewController` 주입 흐름:

1. `Info.plist` 의 `UISceneStoryboardFile=Main` 에 의해 Storyboard 가 `MainViewController` 를 만듬
2. `SceneDelegate.scene(_:willConnectTo:options:)` 에서 `AppDelegate.appContainer.inject(into: mainVC)` 호출
3. `AppContainer` 가 `MainViewModel` 을 resolve 해서 `mainVC.configure(viewModel:)` 로 setter 주입
4. `viewDidAppear` 에서 `viewModel.initialize()` 호출 → 첫 페이지 로딩 시작

이 방식은 `SwinjectStoryboard` 같은 추가 의존 없이 Storyboard+DI 를 붙이는 표준 패턴입니다.

## 설계상 장점

- **방향성 있는 의존성**: Domain 은 Data 를 모르고, Data 는 Domain 프로토콜만 구현.
- **프로토콜 기반 경계**: `SeoulRepository`, `SeoulUsecase`, `SeoulRemoteDataSource` 모두 프로토콜 → Mock 대체가 즉시 가능.
- **단일 Composition Root**: 구체 타입 지식은 `AppContainer` 한 곳에만 존재.
- **생성자 주입 + let + non-optional**: ViewModel / Usecase / Repository / Api 모두 nil 불가능한 의존성으로 구성.
- **에러 타입 일원화**: `SeoulError` 하나로 레이어 간 에러 계약 통일. `LoadState.error(String)` 으로 UI 까지 단일 경로.
- **단방향 데이터 흐름**: `MainViewModel @Published` → Combine sink → ViewController. ViewController 는 상태를 직접 변경하지 않음.
- **mos 기조 정렬**: Android 대응 앱(mos)과 도메인 모델 24필드, `LoadState`, `PAGE_SIZE=50`, `callAsFunction` 패턴이 모두 대응됨.
- **환경 분리 가능**: `NetworkConfig` 교체만으로 dev/stage/prod 분기 준비됨.

## 향후 확장 포인트

- **Local DataSource**: `SeoulLocalDataSource` 프로토콜 + CoreData/SwiftData 구현을 추가하고, `SeoulRepositoryImpl` 이 Remote-First + Fallback 전략으로 조율 (mos 의 Room 전략과 동일).
- **모듈화**: 기능 단위(`Feature/Main`) + 공용(`Core/Network`, `Core/DI`) 로 SPM 로컬 패키지 분리.
- **Coordinator**: 화면 전환이 늘어나면 `Coordinator` 패턴으로 네비게이션을 VC 밖으로 분리.
- **상세 화면**: `MainViewModel` 에서 선택 이벤트를 받아 `CulturalEvent` 전체 24필드를 활용하는 DetailViewModel + DetailViewController.

## mos ↔ S206 대응표

| 개념 | mos (Android/Kotlin) | S206 (iOS/Swift) |
|---|---|---|
| DI | Hilt `@HiltViewModel` | Swinject `AppContainer` |
| 상태 흐름 | `MutableStateFlow` | Combine `@Published` |
| UI 상태 | `sealed interface LoadState` | `enum LoadState` |
| 도메인 모델 | `CulturalEvent` (data class, 24필드) | `CulturalEvent` (struct, 24필드) |
| DTO | `CulturalEventInfoData` | `CulturalEventDTO` |
| 페이지 타입 | `CulturalEventPage` | `CulturalEventPage` |
| UseCase 호출 | `seoulUseCase(start, end)` (`operator fun invoke`) | `usecase(startIndex:endIndex:)` (`callAsFunction`) |
| 페이지 크기 | `PAGE_SIZE = 50` | `pageSize = 50` |
| 페이지네이션 | `initialize()` / `loadNextPage()` / `refresh()` | `initialize()` / `loadNextPage()` / `refresh()` |
| 로컬 캐시 | Room DB (Remote-First + Fallback) | 미구현 (향후 CoreData/SwiftData) |
| UI 프레임워크 | Jetpack Compose | UIKit + Storyboard |
