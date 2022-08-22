//
//  CulturalEventInfoResponse.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

struct CulturalEventInfoResponse: Codable {
    let info: CulturalEventInfo

    enum CodingKeys: String, CodingKey {
        case info = "culturalEventInfo"
    }

    init() {
        info = CulturalEventInfo()
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        info = (try? values.decodeIfPresent(CulturalEventInfo.self, forKey: CodingKeys.info)) ?? CulturalEventInfo()
    }
}
