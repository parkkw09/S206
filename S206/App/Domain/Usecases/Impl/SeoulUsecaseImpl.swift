//
//  SeoulUsecaseImpl.swift
//  S206
//
//  Domain 은 Repository(Domain) 외의 것은 알지 않습니다.
//  매핑과 서버 응답 코드 검증은 Data 레이어로 이동했습니다.
//

import Foundation

final class SeoulUsecaseImpl: SeoulUsecase {

    private let repository: SeoulRepository

    init(repository: SeoulRepository) {
        self.repository = repository
    }

    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> Response<NewCultureEvent> {
        try await repository.getCultureInfo(startIndex: startIndex, endIndex: endIndex)
    }
}
