//
//  SeoulRepositoryImpl.swift
//  S206
//

import Foundation

final class SeoulRepositoryImpl: SeoulRepository {

    private let remote: SeoulRemoteDataSource

    init(remote: SeoulRemoteDataSource) {
        self.remote = remote
    }

    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventPage {
        let dto = try await remote.getCultureInfo(startIndex: startIndex, endIndex: endIndex)
        return try SeoulMapper.toDomain(dto)
    }
}
