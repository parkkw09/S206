//
//  SeoulApi.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation
import Alamofire

enum SeoulError : Error {
    case reponseFailure(message: String)
    case requestFailure(message: String)
}

class SeoulApi : SeoulDataSource  {

    let baseURL = URL(string: "http://openapi.seoul.go.kr:8088")!
    let dataType = "json"
    let command = "culturalEventInfo"

    func getCultureInfo() async throws -> CulturalEventInfoResponse {
        return try await getCultureEventInfo1()
    }

    private func getCultureEventInfo1(startIndex: Int = 1, endIndex: Int = 5) async throws -> CulturalEventInfoResponse {
        print("getCultureEventInfo1() in Api")

        guard let key = Bundle.main.object(forInfoDictionaryKey: "SEOUL_KEY") as? String else {
            throw SeoulError.reponseFailure(message: "api key is nil")
        }

        let requestUrl = "\(baseURL)/\(key)/\(dataType)/\(command)/\(startIndex)/\(endIndex)/"
        print("getCultureEventInfo1() in Api URL[\(requestUrl)]")

        let response = await AF.request(requestUrl,
                                    method: HTTPMethod.get,
                                    parameters: nil,
                                    encoding: URLEncoding.default)
                        .validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .serializingDecodable(CulturalEventInfoResponse.self)
                        .response

        switch response.result {
            case .success(let data):
                print("getCultureEventInfo1() in Api data[\(data)]")
                return data
            case .failure(let error):
                print("getCultureEventInfo1) in Api error[\(error.localizedDescription)]")
                throw SeoulError.reponseFailure(message: error.localizedDescription)
        }
    }

    private func getCultureEventInfo2(startIndex: Int = 1, endIndex: Int = 5) async throws -> CulturalEventInfoResponse {
        print("getCultureEventInfo2() in Api")

        guard let key = Bundle.main.object(forInfoDictionaryKey: "SEOUL_KEY") as? String else {
            throw SeoulError.reponseFailure(message: "api key is nil")
        }

        let requestUrl = "\(baseURL)/\(key)/\(dataType)/\(command)/\(startIndex)/\(endIndex)/"
        print("getCultureEventInfo2() in Api URL[\(requestUrl)]")

        return try await AF.request(requestUrl,
                                    method: HTTPMethod.get,
                                    parameters: nil,
                                    encoding: URLEncoding.default)
                        .validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .serializingDecodable(CulturalEventInfoResponse.self)
                        .value
    }
}
