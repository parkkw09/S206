//
//  S206Repository.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import Foundation

protocol LibraryRepository {
    func getNewBook() async throws -> ListBook
    func getDetailBook(isbn: String) async throws -> DetailBook
    func getSearchBook(query: String, page: String) async throws -> ListBook

    func addBookmark(book: Book)
    func deleteBookmark(book: Book)
    func checkBookmark(book: Book) -> Bool
    func updateBookmark(bookmark: [Book])
    func getBookmark() -> [Book]
    func addHistory(query: String)
    func getHistory() -> [String]
}
