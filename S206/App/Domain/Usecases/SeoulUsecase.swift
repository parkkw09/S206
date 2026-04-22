//
//  SeoulUsecase.swift
//  S206
//

import Foundation

protocol SeoulUsecase {
    func getCultureInfo() async throws -> Response<NewCultureEvent>
    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> Response<NewCultureEvent>
}

extension SeoulUsecase {
    func getCultureInfo() async throws -> Response<NewCultureEvent> {
        try await getCultureInfo(startIndex: 1, endIndex: 5)
    }
}
