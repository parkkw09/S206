//
//  SeoulUsecaseImpl.swift
//  S206
//

import Foundation

final class SeoulUsecaseImpl: SeoulUsecase {

    private let repository: SeoulRepository

    init(repository: SeoulRepository) {
        self.repository = repository
    }

    func callAsFunction(startIndex: Int, endIndex: Int) async throws -> CulturalEventPage {
        try await repository.getCultureInfo(startIndex: startIndex, endIndex: endIndex)
    }
}
