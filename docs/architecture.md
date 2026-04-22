# 아키텍처

S206 은 **Clean Architecture** 스타일의 3-레이어 구조를 따르며, DI 는 **Swinject 기반 단일 Composition Root** 로 구성됩니다.

## 폴더 구조

```
S206/App
├── Data                        # 외부 세계와 맞닿은 레이어
│   ├── Entities                # 서버 JSON 과 1:1 매핑되는 Codable DTO
│   │   └── CulturalEventInfo/
│   │       ├── CulturalEvent.swift
│   │       ├── CulturalEventInfo.swift
│   │       ├── CulturalEventInfoResponse.swift
│   │       └── CulturalEventInfoResult.swift
│   ├── Mapper
│   │   └── SeoulMapper.swift               # DTO → Domain 변환 + 서버 성공코드 검증
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
│   │   ├── NewCultureEvent.swift
│   │   └── Response.swift
│   ├── Repositories
│   │   └── SeoulRepository.swift           # 도메인이 정의하는 Repository 계약
│   └── Usecases
│       ├── SeoulUsecase.swift
│       └── Impl/SeoulUsecaseImpl.swift     # Repository 호출만 하는 얇은 계층
├── DI
│   └── AppContainer.swift                  # Composition Root (Swinject)
├── Presentation                # UIKit
│   └── View/
│       ├── LaunchScreen/LaunchScreen.storyboard
│       └── Main/
│           ├── Main.storyboard
│           └── MainViewController.swift    # Storyboard + setter-injected Usecase
├── AppDelegate.swift                       # AppContainer 소유
└── SceneDelegate.swift                     # Storyboard rootVC 에 주입
```

## 의존성 흐름

```
MainViewController (Presentation)
      │ uses
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

## 데이터 흐름 (정상 경로)

```
[MainViewController.viewDidAppear]
    → usecase.getCultureInfo()                           // async throws
        → repository.getCultureInfo(startIndex:endIndex:)
            → remote.getCultureInfo(startIndex:endIndex:) // SeoulApi
                → AF.request(...)                         // Alamofire
                → serializingDecodable(CulturalEventInfoResponse.self)
        ← CulturalEventInfoResponse (DTO)
        ↓
    SeoulMapper.toDomain(dto)                             // 성공코드 검증 + 매핑
        ↓ (throws SeoulError.server on bad code)
    Response<NewCultureEvent>
        ↓
    tableView.reloadData() / myLabel 갱신
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
```

Storyboard 로 생성된 `MainViewController` 주입 흐름:

1. `Info.plist` 의 `UISceneStoryboardFile=Main` 에 의해 Storyboard 가 `MainViewController` 를 만듬
2. `SceneDelegate.scene(_:willConnectTo:options:)` 에서 `AppDelegate.appContainer.inject(into: mainVC)` 호출
3. `AppContainer` 가 `SeoulUsecase` 를 resolve 해서 `mainVC.configure(usecase:)` 로 setter 주입
4. `viewDidAppear` 에서 `usecase.getCultureInfo()` 호출

이 방식은 `SwinjectStoryboard` 같은 추가 의존 없이 Storyboard+DI 를 붙이는 표준 패턴입니다.

## 설계상 장점

- **방향성 있는 의존성**: Domain 은 Data 를 모르고, Data 는 Domain 프로토콜만 구현.
- **프로토콜 기반 경계**: `SeoulRepository`, `SeoulUsecase`, `SeoulRemoteDataSource` 모두 프로토콜 → Mock 대체가 즉시 가능.
- **단일 Composition Root**: 구체 타입 지식은 `AppContainer` 한 곳에만 존재.
- **생성자 주입 + let + non-optional**: Usecase / Repository / Api 모두 nil 불가능한 의존성으로 구성되어 방어 코드 제거.
- **에러 타입 일원화**: `SeoulError` 하나로 레이어 간 에러 계약 통일.
- **환경 분리 가능**: `NetworkConfig` 교체만으로 dev/stage/prod 분기 준비됨.

## 향후 확장 포인트

- **Local DataSource**: 필요해지면 `SeoulLocalDataSource` 프로토콜 + 구현을 추가하고, `SeoulRepositoryImpl` 이 Remote/Local 을 조율하도록 확장 (캐시·오프라인 전략).
- **MVVM 도입**: `MainViewController` 와 `SeoulUsecase` 사이에 `MainViewModel` 을 넣으면 Presentation 내부에서 상태·바인딩 로직을 분리 가능.
- **모듈화**: 기능 단위(`Feature/Main`) + 공용(`Core/Network`, `Core/DI`) 로 SPM 로컬 패키지 분리.
- **Coordinator**: 화면 전환이 늘어나면 `Coordinator` 패턴으로 네비게이션을 VC 밖으로 분리.
