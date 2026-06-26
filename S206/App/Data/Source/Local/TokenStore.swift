//
//  TokenStore.swift
//  S206
//
//  Google Access Token 영속 저장소. mos 의 Preference(DataStore) 에 대응합니다.
//  인터셉터가 동기적으로 읽을 수 있도록 `currentToken` 을 제공합니다.
//
//  NOTE: mos 의 DataStore 와 동일하게 평문 저장입니다. 운영 단계에서는 Keychain 으로 승격을 권장합니다.
//

import Foundation

protocol TokenStore {
    /// 현재 저장된 토큰 (없으면 nil). 인터셉터가 동기적으로 참조.
    var currentToken: String? { get }
    func saveGoogleAccessToken(_ token: String) async
    func clearGoogleAccessToken() async
}

final class UserDefaultsTokenStore: TokenStore {
    private static let key = "google_access_token"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentToken: String? {
        defaults.string(forKey: Self.key)
    }

    func saveGoogleAccessToken(_ token: String) async {
        defaults.set(token, forKey: Self.key)
    }

    func clearGoogleAccessToken() async {
        defaults.removeObject(forKey: Self.key)
    }
}
