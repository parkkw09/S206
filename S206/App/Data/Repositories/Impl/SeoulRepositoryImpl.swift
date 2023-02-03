//
//  SeoulRepositoryImpl.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

class SeoulRepositoryImpl : SeoulRepository {

    var source: SeoulDataSource? = nil

    init(_source: SeoulDataSource) {
        source = _source
    }

    func getCultureInfo() async throws -> CulturalEventInfoResponse {
        return try await getCultureInfo1()
    }

    func getCultureInfo1() async throws -> CulturalEventInfoResponse {
        print("getCultureInfo1() in SeoulRepository")
        if let source = source {
//            do{
//                let data = try await source.getCultureEventInfo1()
//                print("getCultureInfo1() [\(data)]")
//                return data
//            } catch {
//                print("Unexpected error: \(error).")
//                return SeoulResponse()
//            }
            let data = try await source.getCultureInfo()
            print("getCultureInfo1() [\(data)]")
            return data
        }
        throw SeoulError.requestFailure(message: "Source is NULL.")
    }

    func getCultureInfo2() async throws -> CulturalEventInfoResponse {
        print("getCultureInfo2() in SeoulRepository")
        if let data = try? await source?.getCultureInfo() {
            print("getCultureInfo2() [\(data)]")
            return data
        } else {
            throw SeoulError.requestFailure(message: "Source is NULL.")
        }
    }
}
