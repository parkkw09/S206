//
//  S206Tests.swift
//  S206Tests
//
//  Created by kwp-macbook-pro on 2022/08/05.
//

import XCTest
@testable import S206

class S206Tests: XCTestCase {

    var repository: LibraryRepository? = nil
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        repository = LibraryRepositoryImpl(remote: Api(), local: S206Data())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        repository = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        Task {
            if let data = try await repository?.getNewBook() {
                print(data)
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
