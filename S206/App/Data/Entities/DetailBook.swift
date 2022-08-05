//
//  DetailBook.swift
//  S206
//
//  Created by kwp-macbook-pro on 2022/08/05.
//

import Foundation

struct DetailBook: Codable {
    let error: String
    let title: String
    let subtitle: String
    let authors: String
    let publisher: String
    let language: String
    let isbn10: String
    let isbn13: String
    let pages: String
    let year: String
    let rating: String
    let desc: String
    let price: String
    let image: String
    let url: String
    let pdf: Pdf

    init() {
        self.error = ""
        self.title = ""
        self.subtitle = ""
        self.authors = ""
        self.publisher = ""
        self.language = ""
        self.isbn10 = ""
        self.isbn13 = ""
        self.pages = ""
        self.year = ""
        self.rating = ""
        self.desc = ""
        self.price = ""
        self.image = ""
        self.url = ""
        self.pdf = Pdf()
    }
}

struct Pdf: Codable {
    let freeBook: String

    init() {
        self.freeBook = ""
    }
}
