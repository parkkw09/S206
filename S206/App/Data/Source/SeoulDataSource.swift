//
//  SeoulDataSource.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2023/02/03.
//

import Foundation

protocol SeoulDataSource {
    func getCultureInfo() async throws -> CulturalEventInfoResponse
}
