//
//  S206Local.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import Foundation

class SeoulData : SeoulDataSource {

    func getCultureInfo() async throws -> CulturalEventInfoResponse {
        return response.first ?? CulturalEventInfoResponse()
    }

    var response: [CulturalEventInfoResponse] = []
}
