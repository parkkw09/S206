//
//  SeoulError.swift
//  S206
//
//  Domain 이 외부 레이어 없이 던질 수 있는 에러.
//  Data 레이어는 자신의 에러를 잡아 이 에러로 매핑해서 올려보냅니다.
//

import Foundation

enum SeoulError: Error, Equatable {
    /// 네트워크 계층에서 발생한 실패 (연결, 타임아웃 등).
    case network(message: String)
    /// 디코딩 실패.
    case decoding(message: String)
    /// 서버가 비즈니스적으로 실패로 응답.
    case server(code: String, message: String)
    /// 구성 값 누락 (API 키 등).
    case missingConfiguration(key: String)
    /// 그 외.
    case unknown(message: String)
}

extension SeoulError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network error: \(message)"
        case .decoding(let message):
            return "Decoding error: \(message)"
        case .server(let code, let message):
            return "Server error [\(code)]: \(message)"
        case .missingConfiguration(let key):
            return "Missing configuration: \(key)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
