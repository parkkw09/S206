//
//  SeoulMapper.swift
//  S206
//
//  DTO(Data) → Domain 변환. 서버 성공 코드 검증도 여기서 수행합니다.
//

import Foundation

enum SeoulMapper {
    static let successCode = "INFO-000"

    static func toDomain(_ dto: CulturalEventInfoResponse) throws -> CulturalEventPage {
        let info = dto.info
        let result = info.result

        guard result.code == successCode else {
            throw SeoulError.server(code: result.code, message: result.message)
        }

        return CulturalEventPage(
            events: info.list.map(toDomain),
            totalCount: info.count
        )
    }

    static func toDomain(_ dto: CulturalEventDTO) -> CulturalEvent {
        CulturalEvent(
            codeName:         dto.codeName,
            guName:           dto.guName,
            title:            dto.title,
            date:             dto.date,
            place:            dto.place,
            orgName:          dto.orgName,
            useTarget:        dto.useTarget,
            useFee:           dto.useFee,
            inquiry:          dto.inquiry,
            player:           dto.player,
            program:          dto.program,
            etcDesc:          dto.etcDesc,
            orgLink:          dto.orgLink,
            mainImage:        dto.mainImage,
            registrationDate: dto.registrationDate,
            ticket:           dto.ticket,
            startDate:        dto.startDate,
            endDate:          dto.endDate,
            themeCode:        dto.themeCode,
            lot:              dto.lot,
            lat:              dto.lat,
            isFree:           dto.isFree,
            homepageAddr:     dto.homepageAddr,
            proTime:          dto.proTime
        )
    }
}
