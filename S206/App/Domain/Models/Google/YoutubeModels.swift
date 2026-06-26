//
//  YoutubeModels.swift
//  S206
//
//  YouTube 도메인 모델. 외부 의존성(Codable, JSON 키) 없이 순수 Swift 타입만 사용합니다.
//  mos 의 domain/model/google (Subscription, PlayList, PlayItem) 에 대응합니다.
//

import Foundation

struct Subscription {
    let publishedAt: String
    let title: String
    let description: String
    let resourceId: String
    let channelId: String
    let thumbnails: String
}

struct PlayList {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: String
    let channelTitle: String
    let localized: String
}

struct PlayItem {
    let channelId: String
    let title: String
    let description: String
    let thumbnails: String
    let channelTitle: String
    let playlistId: String
    let resourceId: String
}
