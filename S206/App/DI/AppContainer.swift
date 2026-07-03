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

        registerGoogleDependencies()

        // Presentation layer
        container.register(MainViewModel.self) { resolver in
            MainViewModel(
                usecase: resolver.resolve(SeoulUsecase.self)!,
                saveGoogleTokenUseCase: resolver.resolve(SaveGoogleTokenUseCase.self)!,
                clearGoogleTokenUseCase: resolver.resolve(ClearGoogleTokenUseCase.self)!
            )
        }.inObjectScope(.container)
    }

    // MARK: - Google / YouTube

    private func registerGoogleDependencies() {
        // Infrastructure
        // 토큰 저장/삭제 경로는 GoogleConfig 가 없어도 동작해야 하므로(앱 부팅 차단 방지),
        // GOOGLE_CLIENT_ID 미설정 시 fatalError 대신 빈 clientId fallback 으로 둡니다.
        // 실제 로그인/API 호출 시점에 GoogleError 로 사유가 표면화됩니다.
        container.register(GoogleConfig.self) { _ in
            (try? GoogleConfig.fromBundle()) ?? GoogleConfig(
                apiBaseURL: URL(string: "https://www.googleapis.com")!,
                clientId: "",
                scope: "https://www.googleapis.com/auth/youtube.readonly"
            )
        }.inObjectScope(.container)

        container.register(TokenStore.self) { _ in
            UserDefaultsTokenStore()
        }.inObjectScope(.container)

        // Data layer
        container.register(GoogleRemoteDataSource.self) { resolver in
            GoogleApi(
                config: resolver.resolve(GoogleConfig.self)!,
                tokenStore: resolver.resolve(TokenStore.self)!
            )
        }.inObjectScope(.container)

        container.register(GoogleRepository.self) { resolver in
            GoogleRepositoryImpl(
                remote: resolver.resolve(GoogleRemoteDataSource.self)!,
                tokenStore: resolver.resolve(TokenStore.self)!
            )
        }.inObjectScope(.container)

        // Domain layer — YouTube UseCases
        container.register(GetSubscriptionsUseCase.self) { r in
            GetSubscriptionsUseCaseImpl(repository: r.resolve(GoogleRepository.self)!)
        }.inObjectScope(.container)
        container.register(GetPlaylistUseCase.self) { r in
            GetPlaylistUseCaseImpl(repository: r.resolve(GoogleRepository.self)!)
        }.inObjectScope(.container)
        container.register(GetContentDetailUseCase.self) { r in
            GetContentDetailUseCaseImpl(repository: r.resolve(GoogleRepository.self)!)
        }.inObjectScope(.container)
        container.register(SaveGoogleTokenUseCase.self) { r in
            SaveGoogleTokenUseCaseImpl(repository: r.resolve(GoogleRepository.self)!)
        }.inObjectScope(.container)
        container.register(ClearGoogleTokenUseCase.self) { r in
            ClearGoogleTokenUseCaseImpl(repository: r.resolve(GoogleRepository.self)!)
        }.inObjectScope(.container)
    }

    // MARK: - Google sign-in (presentation-time wiring)
    // Google 로그인은 현재 자동 트리거를 제거한 상태입니다.
    // 향후 명시적 로그인 버튼 도입 시 makeGoogleSignInManager 를 복원합니다.

    // MARK: - Presentation wiring

    func inject(into viewController: MainViewController) {
        guard let viewModel = container.resolve(MainViewModel.self) else {
            fatalError("MainViewModel 을 resolve 하지 못했습니다. AppContainer 등록을 확인하세요.")
        }
        viewController.configure(viewModel: viewModel)
    }
}

