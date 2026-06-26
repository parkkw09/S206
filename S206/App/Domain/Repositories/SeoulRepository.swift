//
//  SeoulRepository.swift
//  S206
//
//  Domain 이 정의하는 Repository 계약.
//

import Foundation

protocol SeoulRepository {
    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventPage
}
