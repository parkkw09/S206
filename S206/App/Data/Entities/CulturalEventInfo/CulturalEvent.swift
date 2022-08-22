//
//  CulturalEvent.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/22.
//

import Foundation

struct CulturalEvent: Codable {
    let codeName: String
    let guName: String
    let title: String
    let date: String
    let place: String
    let orgName: String
    let useTarget: String
    let useFee: String
    let player: String
    let program: String
    let etcDesc: String
    let orgLink: String
    let mainImage: String
    let regisrationDate: String
    let ticket: String
    let startDate: String
    let endDate: String
    let themeCode: String

    enum CodingKeys: String, CodingKey {
        case codeName = "CODENAME"
        case guName = "GUNAME"
        case title = "TITLE"
        case date = "DATE"
        case place = "PLACE"
        case orgName = "ORG_NAME"
        case useTarget = "USE_TRGT"
        case useFee = "USE_FEE"
        case player = "PLAYER"
        case program = "PROGRAM"
        case etcDesc = "ETC_DESC"
        case orgLink = "ORG_LINK"
        case mainImage = "MAIN_IMG"
        case regisrationDate = "RGSTDATE"
        case ticket = "TICKET"
        case startDate = "STRTDATE"
        case endDate = "END_DATE"
        case themeCode = "THEMECODE"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        codeName = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.codeName)) ?? ""
        guName = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.guName)) ?? ""
        title = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.title)) ?? ""
        date = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.date)) ?? ""
        place = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.place)) ?? ""
        orgName = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.orgName)) ?? ""
        useTarget = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.useTarget)) ?? ""
        useFee = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.useFee)) ?? ""
        player = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.player)) ?? ""
        program = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.program)) ?? ""
        etcDesc = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.etcDesc)) ?? ""
        orgLink = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.orgLink)) ?? ""
        mainImage = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.mainImage)) ?? ""
        regisrationDate = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.regisrationDate)) ?? ""
        ticket = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.ticket)) ?? ""
        startDate = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.startDate)) ?? ""
        endDate = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.endDate)) ?? ""
        themeCode = (try? values.decodeIfPresent(String.self, forKey: CodingKeys.themeCode)) ?? ""
    }
}
