//
//  AppContainer.swift
//  S206
//
//  Composition Root. 여기서만 구체 타입을 알고 나머지 레이어는 프로토콜만 봅니다.
//

import Foundation
import Swinject

final class AppContainer {

    let container: Container

    init() {
        self.container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        // Infrastructure
        container.register(NetworkConfig.self) { _ in
            // 부팅 시 1회 로드. 실패 시 fatal: Info.plist 에 SEOUL_KEY 가 없으면 앱이 정상 동작 불가능한 상태.
            do {
                return try NetworkConfig.fromBundle()
            } catch {
                fatalError("NetworkConfig 로드 실패: \(error)")
            }
        }.inObjectScope(.container)

        // Data layer
        container.register(SeoulRemoteDataSource.self) { resolver in
            let config = resolver.resolve(NetworkConfig.self)!
            return SeoulApi(config: config)
        }.inObjectScope(.container)

        container.register(SeoulRepository.self) { resolver in
            let remote = resolver.resolve(SeoulRemoteDataSource.self)!
            return SeoulRepositoryImpl(remote: remote)
        }.inObjectScope(.container)

        // Domain layer
        container.register(SeoulUsecase.self) { resolver in
            let repository = resolver.resolve(SeoulRepository.self)!
            return SeoulUsecaseImpl(repository: repository)
        }.inObjectScope(.container)
    }

    // MARK: - Presentation wiring

    /// Storyboard 로 만들어진 `MainViewController` 에 의존성을 주입합니다.
    /// Storyboard 기반 VC 는 `init(coder:)` 로 생성되므로 프로퍼티 주입이 필요합니다.
    func inject(into viewController: MainViewController) {
        guard let usecase = container.resolve(SeoulUsecase.self) else {
            fatalError("SeoulUsecase 를 resolve 하지 못했습니다. AppContainer 등록을 확인하세요.")
        }
        viewController.configure(usecase: usecase)
    }
}
