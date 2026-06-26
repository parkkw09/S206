//
//  GoogleDataSource.swift
//  S206
//
//  Repository 가 조율할 Google Remote DataSource 계약.
//  mos 의 GoogleApi (Retrofit interface) 에 대응합니다.
//

import Foundation

protocol GoogleRemoteDataSource {
    func getSubscriptionList() async throws -> YoutubeResponse<SubscriptionDTO>
    func getPlayList(channelId: String) async throws -> YoutubeResponse<PlaylistDTO>
    func getPlayItem(playlistId: String) async throws -> YoutubeResponse<PlaylistItemDTO>
}
