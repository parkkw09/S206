//
//  SeoulUsecaseImpl.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/29.
//

import Foundation

class SeoulUsecaseImpl: SeoulUsecase {

    var repository: SeoulRepository? = nil

    init(repo: SeoulRepository?) {
        repository = repo
    }

    func getCultureInfo() async throws -> Response<NewCultureEvent> {
        if let repo = repository {
            let data = try await repo.getCultureInfo1()
            let response = SeoulTranslator.getCultureEventInfo(response: data)
            if (response.code != "INFO-000") {
                throw SeoulError.reponseFailure(message: "response code[\(response.code)], message[\(response.message)]")
            }
            return  response
        }
        throw SeoulError.requestFailure(message: "Repository is NULL.")
    }
}
