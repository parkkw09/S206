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

        // Presentation layer
        container.register(MainViewModel.self) { resolver in
            let usecase = resolver.resolve(SeoulUsecase.self)!
            return MainViewModel(usecase: usecase)
        }.inObjectScope(.container)
    }

    // MARK: - Presentation wiring

    func inject(into viewController: MainViewController) {
        guard let viewModel = container.resolve(MainViewModel.self) else {
            fatalError("MainViewModel 을 resolve 하지 못했습니다. AppContainer 등록을 확인하세요.")
        }
        viewController.configure(viewModel: viewModel)
    }
}
