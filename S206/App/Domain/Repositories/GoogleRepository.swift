//
//  GoogleRepository.swift
//  S206
//
//  Domain 이 정의하는 Google/YouTube Repository 계약.
//  mos 의 domain/repository/GoogleRepository 에 대응합니다.
//

import Foundation

protocol GoogleRepository {
    func getSubscriptions() async throws -> [Subscription]
    func getPlaylist(channelId: String) async throws -> [PlayList]
    func getContentDetail(itemId: String) async throws -> PlayItem
    func saveAccessToken(_ token: String) async
    func clearAccessToken() async
}
