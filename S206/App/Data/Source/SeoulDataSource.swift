//
//  SeoulDataSource.swift
//  S206
//
//  Repository 가 조율할 Remote DataSource 계약.
//  (Local 이 필요해지면 SeoulLocalDataSource 를 별도 프로토콜로 추가합니다.)
//

import Foundation

protocol SeoulRemoteDataSource {
    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventInfoResponse
}
