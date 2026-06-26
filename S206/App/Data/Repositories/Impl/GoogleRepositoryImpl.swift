//
//  GoogleRepositoryImpl.swift
//  S206
//
//  GoogleRepository 구현체: Remote 호출 + Mapper 위임 + 토큰 저장소 조율.
//  mos 의 GoogleRepositoryImpl 에 대응합니다.
//

import Foundation

final class GoogleRepositoryImpl: GoogleRepository {

    private let remote: GoogleRemoteDataSource
    private let tokenStore: TokenStore

    init(remote: GoogleRemoteDataSource, tokenStore: TokenStore) {
        self.remote = remote
        self.tokenStore = tokenStore
    }

    func getSubscriptions() async throws -> [Subscription] {
        let response = try await remote.getSubscriptionList()
        return response.items.map(GoogleMapper.toDomain)
    }

    func getPlaylist(channelId: String) async throws -> [PlayList] {
        let response = try await remote.getPlayList(channelId: channelId)
        return response.items.map(GoogleMapper.toDomain)
    }

    func getContentDetail(itemId: String) async throws -> PlayItem {
        let response = try await remote.getPlayItem(playlistId: itemId)
        guard let item = response.items.first else {
            throw GoogleError.notFound(message: "PlaylistItem not found for itemId: \(itemId)")
        }
        return GoogleMapper.toDomain(item)
    }

    func saveAccessToken(_ token: String) async {
        await tokenStore.saveGoogleAccessToken(token)
    }

    func clearAccessToken() async {
        await tokenStore.clearGoogleAccessToken()
    }
}
