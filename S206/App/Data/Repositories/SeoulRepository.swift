//
//  SeoulRepository.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

protocol SeoulRepository {
    func getCultureInfo() async throws -> CulturalEventInfoResponse
}
