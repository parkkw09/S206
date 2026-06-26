//
//  S206SeoulTests.swift
//  S206Tests
//
//  Mock DataSource 기반 단위 테스트.
//

import XCTest
@testable import S206

// MARK: - Mocks

private final class MockSeoulRemoteDataSource: SeoulRemoteDataSource {
    var stubbedResponse: CulturalEventInfoResponse?
    var stubbedError: Error?
    private(set) var callCount = 0
    private(set) var lastStartIndex: Int?
    private(set) var lastEndIndex: Int?

    func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventInfoResponse {
        callCount += 1
        lastStartIndex = startIndex
        lastEndIndex = endIndex
        if let stubbedError { throw stubbedError }
        if let stubbedResponse { return stubbedResponse }
        return CulturalEventInfoResponse()
    }
}

// MARK: - Fixture builders

private func makeSuccessResponse(
    code: String = SeoulMapper.successCode,
    message: String = "OK",
    count: Int = 1,
    events: [CulturalEventDTO] = []
) -> CulturalEventInfoResponse {
    let json: [String: Any] = [
        "culturalEventInfo": [
            "list_total_count": count,
            "RESULT": ["CODE": code, "MESSAGE": message],
            "row": events.map { event in
                [
                    "CODENAME": event.codeName,
                    "GUNAME": event.guName,
                    "TITLE": event.title,
                    "DATE": event.date,
                    "PLACE": event.place,
                    "ORG_NAME": event.orgName,
                    "USE_TRGT": event.useTarget,
                    "USE_FEE": event.useFee,
                    "INQUIRY": event.inquiry,
                    "PLAYER": event.player,
                    "PROGRAM": event.program,
                    "ETC_DESC": event.etcDesc,
                    "ORG_LINK": event.orgLink,
                    "MAIN_IMG": event.mainImage,
                    "RGSTDATE": event.registrationDate,
                    "TICKET": event.ticket,
                    "STRTDATE": event.startDate,
                    "END_DATE": event.endDate,
                    "THEMECODE": event.themeCode,
                    "LOT": event.lot,
                    "LAT": event.lat,
                    "IS_FREE": event.isFree,
                    "HMPG_ADDR": event.homepageAddr,
                    "PRO_TIME": event.proTime
                ]
            }
        ]
    ]
    let data = try! JSONSerialization.data(withJSONObject: json)
    return try! JSONDecoder().decode(CulturalEventInfoResponse.self, from: data)
}

// MARK: - Tests

final class SeoulRepositoryImplTests: XCTestCase {

    func test_getCultureInfo_성공시_도메인_모델로_매핑된다() async throws {
        let remote = MockSeoulRemoteDataSource()
        remote.stubbedResponse = makeSuccessResponse(count: 2)
        let sut = SeoulRepositoryImpl(remote: remote)

        let result = try await sut.getCultureInfo(startIndex: 1, endIndex: 5)

        XCTAssertEqual(remote.callCount, 1)
        XCTAssertEqual(remote.lastStartIndex, 1)
        XCTAssertEqual(remote.lastEndIndex, 5)
        XCTAssertEqual(result.totalCount, 2)
    }

    func test_getCultureInfo_서버_실패코드면_server_에러를_던진다() async {
        let remote = MockSeoulRemoteDataSource()
        remote.stubbedResponse = makeSuccessResponse(code: "INFO-100", message: "해당하는 데이터가 없습니다")
        let sut = SeoulRepositoryImpl(remote: remote)

        do {
            _ = try await sut.getCultureInfo(startIndex: 1, endIndex: 5)
            XCTFail("서버 실패 코드인데 throw 하지 않았습니다.")
        } catch let SeoulError.server(code, message) {
            XCTAssertEqual(code, "INFO-100")
            XCTAssertEqual(message, "해당하는 데이터가 없습니다")
        } catch {
            XCTFail("기대한 SeoulError.server 가 아님: \(error)")
        }
    }

    func test_getCultureInfo_remote_에러는_그대로_전파된다() async {
        let remote = MockSeoulRemoteDataSource()
        remote.stubbedError = SeoulError.network(message: "timeout")
        let sut = SeoulRepositoryImpl(remote: remote)

        do {
            _ = try await sut.getCultureInfo(startIndex: 1, endIndex: 5)
            XCTFail("throw 해야 합니다.")
        } catch let SeoulError.network(message) {
            XCTAssertEqual(message, "timeout")
        } catch {
            XCTFail("기대한 SeoulError.network 가 아님: \(error)")
        }
    }
}

final class SeoulUsecaseImplTests: XCTestCase {

    private final class StubRepository: SeoulRepository {
        var stubbedResult: Result<CulturalEventPage, Error> = .success(
            CulturalEventPage(events: [], totalCount: 0)
        )
        private(set) var lastStartIndex: Int?
        private(set) var lastEndIndex: Int?

        func getCultureInfo(startIndex: Int, endIndex: Int) async throws -> CulturalEventPage {
            lastStartIndex = startIndex
            lastEndIndex = endIndex
            return try stubbedResult.get()
        }
    }

    func test_callAsFunction_파라미터를_repository에_그대로_전달한다() async throws {
        let repo = StubRepository()
        let sut = SeoulUsecaseImpl(repository: repo)

        _ = try await sut(startIndex: 1, endIndex: 5)

        XCTAssertEqual(repo.lastStartIndex, 1)
        XCTAssertEqual(repo.lastEndIndex, 5)
    }

    func test_callAsFunction_repository_결과를_그대로_반환한다() async throws {
        let repo = StubRepository()
        repo.stubbedResult = .success(CulturalEventPage(events: [], totalCount: 3))
        let sut = SeoulUsecaseImpl(repository: repo)

        let result = try await sut(startIndex: 1, endIndex: 50)

        XCTAssertEqual(result.totalCount, 3)
    }
}

final class SeoulMapperTests: XCTestCase {

    func test_toDomain_성공코드면_이벤트_목록을_도메인으로_변환한다() throws {
        let dto = makeSuccessResponse(count: 1)

        let result = try SeoulMapper.toDomain(dto)

        XCTAssertEqual(result.totalCount, 1)
    }

    func test_toDomain_실패코드면_server_에러를_던진다() {
        let dto = makeSuccessResponse(code: "INFO-100", message: "no data")

        XCTAssertThrowsError(try SeoulMapper.toDomain(dto)) { error in
            guard case SeoulError.server(let code, let message) = error else {
                XCTFail("expected SeoulError.server, got \(error)")
                return
            }
            XCTAssertEqual(code, "INFO-100")
            XCTAssertEqual(message, "no data")
        }
    }
}
