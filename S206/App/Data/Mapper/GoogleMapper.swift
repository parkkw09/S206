//
//  GoogleMapper.swift
//  S206
//
//  YouTube DTO(Data) → Domain 변환. mos 의 GoogleRepositoryImpl 내 toDomain() 확장에 대응합니다.
//

import Foundation

enum GoogleMapper {

    static func toDomain(_ dto: SubscriptionDTO) -> Subscription {
        let s = dto.snippet
        return Subscription(
            publishedAt: s.publishedAt,
            title: s.title,
            description: s.description,
            resourceId: s.resourceId.channelId,
            channelId: s.channelId,
            thumbnails: s.thumbnails.high.url
        )
    }

    static func toDomain(_ dto: PlaylistDTO) -> PlayList {
        let s = dto.snippet
        return PlayList(
            publishedAt: s.publishedAt,
            channelId: s.channelId,
            title: s.title,
            description: s.description,
            thumbnails: s.thumbnails.high.url,
            channelTitle: s.channelTitle,
            localized: "\(s.localized.title) - \(s.localized.description)"
        )
    }

    static func toDomain(_ dto: PlaylistItemDTO) -> PlayItem {
        let s = dto.snippet
        return PlayItem(
            channelId: s.channelId,
            title: s.title,
            description: s.description,
            thumbnails: s.thumbnails.high.url,
            channelTitle: s.channelTitle,
            playlistId: s.playlistId,
            resourceId: s.resourceId.videoId
        )
    }
}
