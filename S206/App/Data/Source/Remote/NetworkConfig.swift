//
//  NetworkConfig.swift
//  S206
//
//  네트워크 호출에 필요한 외부 설정 값.
//  Info.plist 등 특정 소스로부터 분리되어 주입 가능한 형태.
//

import Foundation

struct NetworkConfig {
    let baseURL: URL
    let apiKey: String
    let dataType: String
    let command: String

    /// Info.plist 에서 `SEOUL_KEY` 를 읽어 기본 설정을 만듭니다.
    /// - Throws: `SeoulError.missingConfiguration` 키 부재 시.
    static func fromBundle(_ bundle: Bundle = .main) throws -> NetworkConfig {
        guard let key = bundle.object(forInfoDictionaryKey: "SEOUL_KEY") as? String,
              !key.isEmpty else {
            throw SeoulError.missingConfiguration(key: "SEOUL_KEY")
        }
        return NetworkConfig(
            baseURL: URL(string: "http://openapi.seoul.go.kr:8088")!,
            apiKey: key,
            dataType: "json",
            command: "culturalEventInfo"
        )
    }
}
