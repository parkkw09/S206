//
//  SeoulRepositoryImpl.swift
//  S206
//
//  Repository 구현체: Remote 에서 DTO 를 받아 Domain 모델로 매핑하고
//  서버 응답 코드 검증(SeoulMapper) 까지 마친 뒤 상위 레이어에 전달합니다.
//

import Foundation

final class SeoulRepositoryImpl: SeoulRepository {

    private let remote: SeoulRemoteDataSource

    init(remote: SeoulRemoteDataSource) {
        self.remote = remote
    }

    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> Response<NewCultureEvent> {
        let dto = try await remote.getCultureInfo(startIndex: startIndex, endIndex: endIndex)
        return try SeoulMapper.toDomain(dto)
    }
}
