//
//  S206SeoulTests.swift
//  S206Tests
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import XCTest
@testable import S206

class S206SeoulTests: XCTestCase {

    var repository: SeoulRepository? = nil
    var usecase: SeoulUsecase? = nil

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        repository = SeoulRepositoryImpl(remote: SeoulApi())
        usecase = SeoulUsecaseImpl(repo: repository)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetCultureInfoInRepository1() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        Task {
            do {
                if let data = try await repository?.getCultureInfo1() {
                    print("testGetCultureInfoInRepository1() result[\(data)]")
                } else {
                    throw SeoulError.requestFailure(message: "repository is NULL")
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }

    func testGetCultureInfoInRepository2() throws {
        Task {
            do {
                if let data = try await repository?.getCultureInfo2() {
                    print("testGetCultureInfoInRepository2() result[\(data)]")
                } else {
                    throw SeoulError.requestFailure(message: "repository is NULL")
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }

    func testGetCultureInfoInUsecase() throws {
        Task {
            do {
                if let data = try await usecase?.getCultureInfo() {
                    print("testGetCultureInfoInUsecase() result[\(data)]")
                } else {
                    throw SeoulError.requestFailure(message: "usecase is NULL")
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
