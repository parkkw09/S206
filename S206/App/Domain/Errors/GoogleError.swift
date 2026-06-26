//
//  GoogleError.swift
//  S206
//
//  Google / YouTube 도메인이 외부 레이어 없이 던질 수 있는 에러.
//  Data·인증 레이어는 자신의 에러를 잡아 이 에러로 매핑해서 올려보냅니다.
//

import Foundation

enum GoogleError: Error, Equatable {
    /// 네트워크 계층에서 발생한 실패 (연결, 타임아웃 등).
    case network(message: String)
    /// 디코딩 실패.
    case decoding(message: String)
    /// 인증되지 않음 / 토큰 없음 또는 만료 (401).
    case unauthorized
    /// 사용자가 로그인 플로우를 취소.
    case cancelled
    /// 구성 값 누락 (OAuth 클라이언트 ID 등).
    case missingConfiguration(key: String)
    /// 기대한 리소스를 찾을 수 없음.
    case notFound(message: String)
    /// 그 외.
    case unknown(message: String)
}

extension GoogleError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network error: \(message)"
        case .decoding(let message):
            return "Decoding error: \(message)"
        case .unauthorized:
            return "Unauthorized: 로그인이 필요하거나 토큰이 만료되었습니다."
        case .cancelled:
            return "Cancelled: 인증이 취소되었습니다."
        case .missingConfiguration(let key):
            return "Missing configuration: \(key)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
