//
//  SeoulMapper.swift
//  S206
//
//  DTO(Data) ↔ Entity(Domain) 변환자.
//  DTO 스키마를 아는 쪽은 Data 레이어이므로 매퍼 역시 Data 에 위치합니다.
//

import Foundation

enum SeoulMapper {
    /// 서울시 OpenAPI 성공 코드.
    static let successCode = "INFO-000"

    /// Remote 응답 DTO 를 Domain 모델로 변환하면서 서버 성공 코드를 검증합니다.
    /// - Throws: `SeoulError.server` 성공 코드가 아닐 때.
    static func toDomain(_ dto: CulturalEventInfoResponse) throws -> Response<NewCultureEvent> {
        let info = dto.info
        let result = info.result

        guard result.code == successCode else {
            throw SeoulError.server(code: result.code, message: result.message)
        }

        let list = info.list.map(Self.toDomain(_:))
        return Response(
            count: info.count,
            code: result.code,
            message: result.message,
            list: list
        )
    }

    static func toDomain(_ dto: CulturalEvent) -> NewCultureEvent {
        NewCultureEvent(
            codeName: dto.codeName,
            guName: dto.guName,
            title: dto.title,
            date: dto.date,
            place: dto.place,
            orgName: dto.orgName,
            useTarget: dto.useTarget,
            useFee: dto.useFee,
            player: dto.player,
            program: dto.program,
            etcDesc: dto.etcDesc,
            orgLink: dto.orgLink,
            mainImage: dto.mainImage,
            regisrationDate: dto.regisrationDate,
            ticket: dto.ticket,
            startDate: dto.startDate,
            endDate: dto.endDate,
            themeCode: dto.themeCode
        )
    }
}
