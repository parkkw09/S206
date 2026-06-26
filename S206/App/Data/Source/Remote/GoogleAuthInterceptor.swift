//
//  GoogleAuthInterceptor.swift
//  S206
//
//  모든 Google API 요청에 `Authorization: Bearer <token>` 헤더를 주입하는 Alamofire 인터셉터.
//  mos 의 tool/network/GoogleAuthInterceptor (OkHttp Interceptor) 에 대응합니다.
//

import Foundation
import Alamofire

final class GoogleAuthInterceptor: RequestInterceptor {

    private let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let token = tokenStore.currentToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }
}
