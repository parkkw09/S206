//
//  SeoulApi.swift
//  S206
//

import Foundation
import Alamofire

final class SeoulApi: SeoulRemoteDataSource {

    private let config: NetworkConfig
    private let session: Session

    init(config: NetworkConfig, session: Session = .default) {
        self.config = config
        self.session = session
    }

    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventInfoResponse {
        let url = buildURL(startIndex: startIndex, endIndex: endIndex)

        let task = session.request(url,
                                   method: .get,
                                   parameters: nil,
                                   encoding: URLEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .serializingDecodable(CulturalEventInfoResponse.self)

        let response = await task.response

        switch response.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw Self.mapToSeoulError(error)
        }
    }

    private func buildURL(startIndex: Int, endIndex: Int) -> String {
        let base = config.baseURL.absoluteString
        return "\(base)/\(config.apiKey)/\(config.dataType)/\(config.command)/\(startIndex)/\(endIndex)/"
    }

    private static func mapToSeoulError(_ error: AFError) -> SeoulError {
        switch error {
        case .responseSerializationFailed:
            return .decoding(message: error.localizedDescription)
        case .sessionTaskFailed, .invalidURL, .requestAdaptationFailed, .requestRetryFailed:
            return .network(message: error.localizedDescription)
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
