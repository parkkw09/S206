//
//  ListBook.swift
//  S206
//
//  Created by kwp-macbook-pro on 2022/08/05.
//

import Foundation

struct ListBook: Codable {
    let error: String
    let total: String
    let page: String
    let books: [Book]

    enum CodingKeys: String, CodingKey {
        case error = "error"
        case total = "total"
        case page = "page"
        case books = "books"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        error = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.error)) ?? ""
        total = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.total)) ?? ""
        page = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.page)) ?? ""
        books = (try? values.decodeIfPresent([Book].self, forKey: CodingKeys.books)) ?? []
    }

    init() {
        self.error = ""
        self.total = ""
        self.page = "1"
        self.books = []
    }
}
