//
//  SeoulRepository.swift
//  S206
//
//  Domain 이 정의하는 Repository 계약.
//  구현체는 Data 레이어에 존재하며 Dependency Inversion 을 만족합니다.
//

import Foundation

protocol SeoulRepository {
    /// 서울시 문화행사 정보를 조회합니다.
    /// - Parameters:
    ///   - startIndex: 1 기반 시작 인덱스
    ///   - endIndex:   1 기반 끝 인덱스 (포함)
    /// - Returns: 도메인 모델 `Response<NewCultureEvent>`
    /// - Throws: `SeoulError`
    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> Response<NewCultureEvent>
}
