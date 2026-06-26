//
//  SeoulUsecase.swift
//  S206
//
//  callAsFunction 으로 정의해 `try await usecase(startIndex:endIndex:)` 형태로 호출 가능합니다.
//  mos 의 `operator fun invoke` 와 동일한 의도입니다.
//

import Foundation

protocol SeoulUsecase {
    func callAsFunction(startIndex: Int, endIndex: Int) async throws -> CulturalEventPage
}
