//
//  CulturalEventInfoResult.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

struct CulturalEventInfoResult: Codable {
    let code: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case code = "CODE"
        case message = "MESSAGE"
    }

    init() {
        code = ""
        message = ""
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.code)) ?? ""
        message = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.message)) ?? ""
    }
}
