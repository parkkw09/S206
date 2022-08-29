//
//  SeoulTranslator.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2021/12/06.
//

import Foundation

class SeoulTranslator {
    static func getCultureEventInfo(response: CulturalEventInfoResponse) -> Response<NewCultureEvent> {
        let count: Int = response.info.count
        let code: String = response.info.result.code
        let message: String = response.info.result.message
        let list: [NewCultureEvent] = response.info.list.map { culturalEventInfo in
            NewCultureEvent(
                codeName: culturalEventInfo.codeName,
                guName: culturalEventInfo.guName,
                title: culturalEventInfo.title,
                date: culturalEventInfo.date,
                place: culturalEventInfo.place,
                orgName: culturalEventInfo.orgName,
                useTarget: culturalEventInfo.useTarget,
                useFee: culturalEventInfo.useFee,
                player: culturalEventInfo.player,
                program: culturalEventInfo.program,
                etcDesc: culturalEventInfo.etcDesc,
                orgLink: culturalEventInfo.orgLink,
                mainImage: culturalEventInfo.mainImage,
                regisrationDate: culturalEventInfo.regisrationDate,
                ticket: culturalEventInfo.ticket,
                startDate: culturalEventInfo.startDate,
                endDate: culturalEventInfo.endDate,
                themeCode: culturalEventInfo.themeCode
            )
        }
        return Response(
            count: count, code: code, message: message, list: list
        )
    }
}
