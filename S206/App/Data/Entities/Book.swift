//
//  S206Entity.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import Foundation

struct Book: Codable {
    let isbn: String
    let title: String
    let price: String
    let image: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case isbn = "isbn13"
        case title = "title"
        case price = "price"
        case image = "image"
        case url = "url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isbn = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.isbn)) ?? ""
        title = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.title)) ?? ""
        price = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.price)) ?? ""
        image = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.image)) ?? ""
        url = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.url)) ?? ""
    }
}
