//
//  LibraryRepositoryImpl.swift
//  S206
//
//  Created by kwp-macbook-pro on 2022/08/05.
//

import Foundation

class LibraryRepositoryImpl: LibraryRepository {

    var remoteSource: LibraryApi? = nil
    var localSource: S206Data? = nil

    init(remote: LibraryApi, local: S206Data) {
        remoteSource = remote
        localSource = local
    }

    func getNewBook() async throws -> ListBook {
        print("getNewBook() in LibraryRepository")
        if let source = remoteSource {
            if let data = try? await source.getNewBook() {
                print("getNewBook() [\(data)]")
                return data
            }
        }
        return ListBook()
    }
    
    func getDetailBook(isbn: String) async throws -> DetailBook {
        return try await remoteSource?.getDetailBook(isbn: isbn) ?? DetailBook()
    }
    
    func getSearchBook(query: String, page: String) async throws -> ListBook {
        return try await remoteSource?.getSearchBook(query: query, page: page) ?? ListBook()
    }
    
    func addBookmark(book: Book) {
    }
    
    func deleteBookmark(book: Book) {
    }
    
    func checkBookmark(book: Book) -> Bool {
        return false
    }
    
    func updateBookmark(bookmark: [Book]) {
    }
    
    func getBookmark() -> [Book] {
        return []
    }
    
    func addHistory(query: String) {
    }
    
    func getHistory() -> [String] {
        return []
    }
    
    
}
