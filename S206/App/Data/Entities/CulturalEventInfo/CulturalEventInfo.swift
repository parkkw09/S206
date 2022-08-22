//
//  CulturalEventInfo.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

struct CulturalEventInfo: Codable {
    let count: Int
    let result: CulturalEventInfoResult
    let list: [CulturalEvent]

    enum CodingKeys: String, CodingKey {
        case count = "list_total_count"
        case result = "RESULT"
        case list = "row"
    }

    init() {
        count = 0
        result = CulturalEventInfoResult()
        list = []
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        count = (try? values.decodeIfPresent(Int.self, forKey: CodingKeys.count)) ?? 0
        result = (try? values.decodeIfPresent(CulturalEventInfoResult.self, forKey: CodingKeys.result)) ?? CulturalEventInfoResult()
        list = (try? values.decodeIfPresent([CulturalEvent].self, forKey: CodingKeys.list)) ?? []
    }
}
