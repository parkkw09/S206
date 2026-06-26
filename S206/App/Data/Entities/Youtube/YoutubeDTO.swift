//
//  YoutubeDTO.swift
//  S206
//
//  YouTube Data API v3 응답 DTO. 서버 JSON 과 1:1 매핑되는 Codable 타입.
//  mos 의 data/source/model/google/youtube 패키지에 대응합니다.
//

import Foundation

// MARK: - Generic wrapper

struct YoutubeResponse<T: Codable>: Codable {
    let kind: String
    let etag: String
    let pageInfo: PageInfo
    let items: [T]

    enum CodingKeys: String, CodingKey {
        case kind, etag, pageInfo, items
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = (try? c.decodeIfPresent(String.self, forKey: .kind)) ?? ""
        etag = (try? c.decodeIfPresent(String.self, forKey: .etag)) ?? ""
        pageInfo = (try? c.decodeIfPresent(PageInfo.self, forKey: .pageInfo)) ?? PageInfo()
        items = (try? c.decodeIfPresent([T].self, forKey: .items)) ?? []
    }
}

struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int

    init() {
        totalResults = 0
        resultsPerPage = 0
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        totalResults = (try? c.decodeIfPresent(Int.self, forKey: .totalResults)) ?? 0
        resultsPerPage = (try? c.decodeIfPresent(Int.self, forKey: .resultsPerPage)) ?? 0
    }
}

// MARK: - Shared thumbnails / localized

struct ThumbnailsInfo: Codable {
    let url: String

    init(url: String = "") { self.url = url }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        url = (try? c.decodeIfPresent(String.self, forKey: .url)) ?? ""
    }
}

struct Localized: Codable {
    let title: String
    let description: String

    init() {
        title = ""
        description = ""
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? c.decodeIfPresent(String.self, forKey: .title)) ?? ""
        description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
    }
}

/// default/medium/high 3종 중 high 만 도메인에서 사용하므로 high 만 디코딩합니다.
struct ThumbnailSet: Codable {
    let high: ThumbnailsInfo

    init(high: ThumbnailsInfo = ThumbnailsInfo()) { self.high = high }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        high = (try? c.decodeIfPresent(ThumbnailsInfo.self, forKey: .high)) ?? ThumbnailsInfo()
    }

    enum CodingKeys: String, CodingKey { case high }
}

// MARK: - Subscriptions

struct SubscriptionDTO: Codable {
    let snippet: SubscriptionSnippet

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        snippet = (try? c.decodeIfPresent(SubscriptionSnippet.self, forKey: .snippet)) ?? SubscriptionSnippet()
    }

    enum CodingKeys: String, CodingKey { case snippet }
}

struct SubscriptionSnippet: Codable {
    let publishedAt: String
    let title: String
    let description: String
    let resourceId: ResourceIdentity
    let channelId: String
    let thumbnails: ThumbnailSet

    init() {
        publishedAt = ""
        title = ""
        description = ""
        resourceId = ResourceIdentity()
        channelId = ""
        thumbnails = ThumbnailSet()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        publishedAt = (try? c.decodeIfPresent(String.self, forKey: .publishedAt)) ?? ""
        title = (try? c.decodeIfPresent(String.self, forKey: .title)) ?? ""
        description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        resourceId = (try? c.decodeIfPresent(ResourceIdentity.self, forKey: .resourceId)) ?? ResourceIdentity()
        channelId = (try? c.decodeIfPresent(String.self, forKey: .channelId)) ?? ""
        thumbnails = (try? c.decodeIfPresent(ThumbnailSet.self, forKey: .thumbnails)) ?? ThumbnailSet()
    }
}

struct ResourceIdentity: Codable {
    let channelId: String
    let videoId: String

    init() {
        channelId = ""
        videoId = ""
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        channelId = (try? c.decodeIfPresent(String.self, forKey: .channelId)) ?? ""
        videoId = (try? c.decodeIfPresent(String.self, forKey: .videoId)) ?? ""
    }
}

// MARK: - Playlists

struct PlaylistDTO: Codable {
    let snippet: PlaylistSnippet

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        snippet = (try? c.decodeIfPresent(PlaylistSnippet.self, forKey: .snippet)) ?? PlaylistSnippet()
    }

    enum CodingKeys: String, CodingKey { case snippet }
}

struct PlaylistSnippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: ThumbnailSet
    let channelTitle: String
    let localized: Localized

    init() {
        publishedAt = ""
        channelId = ""
        title = ""
        description = ""
        thumbnails = ThumbnailSet()
        channelTitle = ""
        localized = Localized()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        publishedAt = (try? c.decodeIfPresent(String.self, forKey: .publishedAt)) ?? ""
        channelId = (try? c.decodeIfPresent(String.self, forKey: .channelId)) ?? ""
        title = (try? c.decodeIfPresent(String.self, forKey: .title)) ?? ""
        description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        thumbnails = (try? c.decodeIfPresent(ThumbnailSet.self, forKey: .thumbnails)) ?? ThumbnailSet()
        channelTitle = (try? c.decodeIfPresent(String.self, forKey: .channelTitle)) ?? ""
        localized = (try? c.decodeIfPresent(Localized.self, forKey: .localized)) ?? Localized()
    }
}

// MARK: - Playlist items

struct PlaylistItemDTO: Codable {
    let snippet: PlaylistItemSnippet

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        snippet = (try? c.decodeIfPresent(PlaylistItemSnippet.self, forKey: .snippet)) ?? PlaylistItemSnippet()
    }

    enum CodingKeys: String, CodingKey { case snippet }
}

struct PlaylistItemSnippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: ThumbnailSet
    let channelTitle: String
    let playlistId: String
    let resourceId: ResourceIdentity

    init() {
        publishedAt = ""
        channelId = ""
        title = ""
        description = ""
        thumbnails = ThumbnailSet()
        channelTitle = ""
        playlistId = ""
        resourceId = ResourceIdentity()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        publishedAt = (try? c.decodeIfPresent(String.self, forKey: .publishedAt)) ?? ""
        channelId = (try? c.decodeIfPresent(String.self, forKey: .channelId)) ?? ""
        title = (try? c.decodeIfPresent(String.self, forKey: .title)) ?? ""
        description = (try? c.decodeIfPresent(String.self, forKey: .description)) ?? ""
        thumbnails = (try? c.decodeIfPresent(ThumbnailSet.self, forKey: .thumbnails)) ?? ThumbnailSet()
        channelTitle = (try? c.decodeIfPresent(String.self, forKey: .channelTitle)) ?? ""
        playlistId = (try? c.decodeIfPresent(String.self, forKey: .playlistId)) ?? ""
        resourceId = (try? c.decodeIfPresent(ResourceIdentity.self, forKey: .resourceId)) ?? ResourceIdentity()
    }
}
