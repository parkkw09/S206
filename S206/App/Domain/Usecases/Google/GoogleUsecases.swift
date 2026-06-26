//
//  GoogleUsecases.swift
//  S206
//
//  Google/YouTube UseCase 모음. mos 의 GoogleUseCase.kt 5개 클래스에 대응합니다.
//  각 UseCase 는 `callAsFunction` 으로 정의해 `try await useCase(...)` 형태로 호출합니다.
//  (mos 의 `operator fun invoke` 와 동일 의도.)
//

import Foundation

protocol GetSubscriptionsUseCase {
    func callAsFunction() async throws -> [Subscription]
}

protocol GetPlaylistUseCase {
    func callAsFunction(channelId: String) async throws -> [PlayList]
}

protocol GetContentDetailUseCase {
    func callAsFunction(itemId: String) async throws -> PlayItem
}

protocol SaveGoogleTokenUseCase {
    func callAsFunction(_ token: String) async
}

protocol ClearGoogleTokenUseCase {
    func callAsFunction() async
}

// MARK: - Implementations

final class GetSubscriptionsUseCaseImpl: GetSubscriptionsUseCase {
    private let repository: GoogleRepository
    init(repository: GoogleRepository) { self.repository = repository }

    func callAsFunction() async throws -> [Subscription] {
        try await repository.getSubscriptions()
    }
}

final class GetPlaylistUseCaseImpl: GetPlaylistUseCase {
    private let repository: GoogleRepository
    init(repository: GoogleRepository) { self.repository = repository }

    func callAsFunction(channelId: String) async throws -> [PlayList] {
        try await repository.getPlaylist(channelId: channelId)
    }
}

final class GetContentDetailUseCaseImpl: GetContentDetailUseCase {
    private let repository: GoogleRepository
    init(repository: GoogleRepository) { self.repository = repository }

    func callAsFunction(itemId: String) async throws -> PlayItem {
        try await repository.getContentDetail(itemId: itemId)
    }
}

final class SaveGoogleTokenUseCaseImpl: SaveGoogleTokenUseCase {
    private let repository: GoogleRepository
    init(repository: GoogleRepository) { self.repository = repository }

    func callAsFunction(_ token: String) async {
        await repository.saveAccessToken(token)
    }
}

final class ClearGoogleTokenUseCaseImpl: ClearGoogleTokenUseCase {
    private let repository: GoogleRepository
    init(repository: GoogleRepository) { self.repository = repository }

    func callAsFunction() async {
        await repository.clearAccessToken()
    }
}
