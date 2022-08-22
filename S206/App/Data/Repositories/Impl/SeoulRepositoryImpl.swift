//
//  SeoulRepositoryImpl.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

class SeoulRepositoryImpl : SeoulRepository {

    var source: SeoulApi? = nil

    init(remote: SeoulApi) {
        source = remote
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
            let data = try await source.getCultureEventInfo1()
            print("getCultureInfo1() [\(data)]")
            return data
        }
        print("Source is NULL.")
        return CulturalEventInfoResponse()
    }

    func getCultureInfo2() async throws -> CulturalEventInfoResponse {
        print("getCultureInfo2() in SeoulRepository")
        if let source = source {
//            if let data = try? await source.getCultureEventInfo2() {
//                print("getCultureInfo2() [\(data)]")
//                return data
//            }
            let data = try await source.getCultureEventInfo2()
            print("getCultureInfo2() [\(data)]")
            return data
        }
        return CulturalEventInfoResponse()
    }
}
