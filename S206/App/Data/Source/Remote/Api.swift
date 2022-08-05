//
//  WeatherApi.swift
//  S206
//
//  Created by kwp-macbook-pro on 2022/08/05.
//

import Foundation
import Alamofire

class Api  {

    let baseURL = URL(string: "https://api.itbook.store")!

    func getNewBook() async throws -> ListBook {
        print("getNewBook() in Api")
        return try await AF.request("\(baseURL)/1.0/new",
                                    method: HTTPMethod.get,
                                    parameters: nil,
                                    encoding: URLEncoding.default)
                        .validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .serializingDecodable()
                        .value
    }

    func getDetailBook(isbn: String) async throws -> DetailBook {
        return try await AF.request("\(baseURL)/1.0/books/\(isbn)",
                                    method: HTTPMethod.get,
                                    parameters: nil,
                                    encoding: URLEncoding.default)
                        .validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .serializingDecodable()
                        .value
    }

    func getSearchBook(query: String, page: String) async throws -> ListBook {
        return try await AF.request("\(baseURL)/1.0/search/\(query)/\(page)",
                                    method: HTTPMethod.get,
                                    parameters: nil,
                                    encoding: URLEncoding.default)
                        .validate(statusCode: 200..<500)
                        .validate(contentType: ["application/json"])
                        .serializingDecodable()
                        .value
    }
}
