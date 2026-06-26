//
//  GoogleApi.swift
//  S206
//
//  YouTube Data API v3 Remote 구현체. Alamofire 사용 + GoogleAuthInterceptor 로 Bearer 토큰 주입.
//  mos 의 GoogleApi (Retrofit) + NetworkModule.provideGoogleApi 에 대응합니다.
//

import Foundation
import Alamofire

final class GoogleApi: GoogleRemoteDataSource {

    private let config: GoogleConfig
    private let session: Session

    init(config: GoogleConfig, tokenStore: TokenStore, session: Session? = nil) {
        self.config = config
        if let session {
            self.session = session
        } else {
            self.session = Session(interceptor: GoogleAuthInterceptor(tokenStore: tokenStore))
        }
    }

    func getSubscriptionList() async throws -> YoutubeResponse<SubscriptionDTO> {
        try await request(
            path: "youtube/v3/subscriptions",
            parameters: [
                "part": "snippet,contentDetails",
                "mine": "true",
                "maxResults": "50"
            ]
        )
    }

    func getPlayList(channelId: String) async throws -> YoutubeResponse<PlaylistDTO> {
        try await request(
            path: "youtube/v3/playlists",
            parameters: [
                "channelId": channelId,
                "part": "snippet,status",
                "maxResults": "50"
            ]
        )
    }

    func getPlayItem(playlistId: String) async throws -> YoutubeResponse<PlaylistItemDTO> {
        try await request(
            path: "youtube/v3/playlistItems",
            parameters: [
                "playlistId": playlistId,
                "part": "snippet",
                "maxResults": "50"
            ]
        )
    }

    // MARK: - Private

    private func request<T: Codable>(path: String, parameters: [String: String]) async throws -> T {
        let url = config.apiBaseURL.appendingPathComponent(path)

        let task = session.request(url,
                                   method: .get,
                                   parameters: parameters,
                                   encoding: URLEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .serializingDecodable(T.self)

        let response = await task.response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw Self.mapToGoogleError(error, statusCode: response.response?.statusCode)
        }
    }

    private static func mapToGoogleError(_ error: AFError, statusCode: Int?) -> GoogleError {
        if statusCode == 401 { return .unauthorized }

        switch error {
        case .responseSerializationFailed:
            return .decoding(message: error.localizedDescription)
        case .sessionTaskFailed, .invalidURL, .requestAdaptationFailed, .requestRetryFailed:
            return .network(message: error.localizedDescription)
        case .responseValidationFailed:
            return .network(message: error.localizedDescription)
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
