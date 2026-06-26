//
//  GoogleSignInManager.swift
//  S206
//
//  Google OAuth 2.0 로그인 래퍼. mos 의 GoogleSignInManager (Google Identity SDK) 에 대응하며,
//  iOS 에서는 추가 SDK 없이 시스템 제공 `ASWebAuthenticationSession` 으로 동일한 흐름을 구현합니다.
//
//  흐름: 인증 URL 오픈 → 사용자 동의 → 역방향 클라이언트 ID 스킴으로 리다이렉트 →
//        URL fragment 에서 access_token 추출 (implicit flow) → 토큰 반환.
//

import Foundation
import AuthenticationServices

protocol GoogleSignInManaging {
    /// 사용자 동의를 거쳐 YouTube readonly access token 을 반환합니다.
    /// - Throws: `GoogleError.cancelled` 사용자가 취소한 경우, 그 외 `GoogleError`.
    func signIn() async throws -> String
}

final class GoogleSignInManager: NSObject, GoogleSignInManaging {

    private let config: GoogleConfig
    private let anchorProvider: () -> ASPresentationAnchor
    private var session: ASWebAuthenticationSession?

    init(config: GoogleConfig, anchorProvider: @escaping () -> ASPresentationAnchor) {
        self.config = config
        self.anchorProvider = anchorProvider
    }

    func signIn() async throws -> String {
        let authURL = try buildAuthorizationURL()

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: config.redirectScheme
            ) { callbackURL, error in
                if let error {
                    if let asError = error as? ASWebAuthenticationSessionError,
                       asError.code == .canceledLogin {
                        continuation.resume(throwing: GoogleError.cancelled)
                    } else {
                        continuation.resume(throwing: GoogleError.unknown(message: error.localizedDescription))
                    }
                    return
                }

                guard let callbackURL,
                      let token = Self.extractAccessToken(from: callbackURL) else {
                    continuation.resume(throwing: GoogleError.unauthorized)
                    return
                }
                continuation.resume(returning: token)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.session = session

            if !session.start() {
                continuation.resume(throwing: GoogleError.unknown(message: "인증 세션을 시작하지 못했습니다."))
            }
        }
    }

    // MARK: - Private

    private func buildAuthorizationURL() throws -> URL {
        guard !config.clientId.isEmpty else {
            throw GoogleError.missingConfiguration(key: "GOOGLE_CLIENT_ID")
        }
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: config.scope),
            URLQueryItem(name: "include_granted_scopes", value: "true")
        ]
        guard let url = components.url else {
            throw GoogleError.unknown(message: "인증 URL 생성 실패")
        }
        return url
    }

    /// implicit flow 의 리다이렉트 URL fragment (`#access_token=...&...`) 에서 토큰을 추출합니다.
    private static func extractAccessToken(from url: URL) -> String? {
        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment else {
            return nil
        }
        for pair in fragment.components(separatedBy: "&") {
            let kv = pair.components(separatedBy: "=")
            if kv.count == 2, kv[0] == "access_token" {
                return kv[1].removingPercentEncoding ?? kv[1]
            }
        }
        return nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GoogleSignInManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchorProvider()
    }
}
