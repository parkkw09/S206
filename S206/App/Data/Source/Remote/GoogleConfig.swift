//
//  GoogleConfig.swift
//  S206
//
//  Google/YouTube 호출에 필요한 외부 설정 값.
//  Info.plist 의 GOOGLE_CLIENT_ID 로부터 분리되어 주입 가능한 형태.
//

import Foundation

struct GoogleConfig {
    /// YouTube Data API v3 베이스 URL.
    let apiBaseURL: URL
    /// OAuth 2.0 iOS 클라이언트 ID.
    let clientId: String
    /// 요청하는 OAuth scope.
    let scope: String

    /// ASWebAuthenticationSession 콜백에 사용할 URL 스킴 (역방향 클라이언트 ID).
    /// 예: client `123-abc.apps.googleusercontent.com` → scheme `com.googleusercontent.apps.123-abc`
    var redirectScheme: String {
        let parts = clientId.components(separatedBy: ".")
        return parts.reversed().joined(separator: ".")
    }

    var redirectURI: String { "\(redirectScheme):/oauth2redirect" }

    /// Info.plist 에서 `GOOGLE_CLIENT_ID` 를 읽어 기본 설정을 만듭니다.
    /// - Throws: `GoogleError.missingConfiguration` 키 부재 시.
    static func fromBundle(_ bundle: Bundle = .main) throws -> GoogleConfig {
        guard let clientId = bundle.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String,
              !clientId.isEmpty else {
            throw GoogleError.missingConfiguration(key: "GOOGLE_CLIENT_ID")
        }
        return GoogleConfig(
            apiBaseURL: URL(string: "https://www.googleapis.com")!,
            clientId: clientId,
            scope: "https://www.googleapis.com/auth/youtube.readonly"
        )
    }
}
