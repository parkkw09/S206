//
//  CulturalEvent.swift
//  S206
//
//  서울 문화행사 API Row 항목 DTO. JSON 키 ↔ Swift 프로퍼티 매핑 전담.
//

import Foundation

struct CulturalEventDTO: Codable {
    let codeName: String         // 1.  분류
    let guName: String           // 2.  자치구
    let title: String            // 3.  공연/행사명
    let date: String             // 4.  날짜
    let place: String            // 5.  장소
    let orgName: String          // 6.  기관명
    let useTarget: String        // 7.  이용대상
    let useFee: String           // 8.  이용요금
    let inquiry: String          // 9.  문의
    let player: String           // 10. 출연자정보
    let program: String          // 11. 프로그램소개
    let etcDesc: String          // 12. 기타내용
    let orgLink: String          // 13. 홈페이지 주소
    let mainImage: String        // 14. 대표이미지
    let registrationDate: String // 15. 신청일
    let ticket: String           // 16. 시민/기관
    let startDate: String        // 17. 시작일
    let endDate: String          // 18. 종료일
    let themeCode: String        // 19. 테마분류
    let lot: String              // 20. 경도(Y좌표)
    let lat: String              // 21. 위도(X좌표)
    let isFree: String           // 22. 유무료
    let homepageAddr: String     // 23. 문화포털상세URL
    let proTime: String          // 24. 행사시간

    enum CodingKeys: String, CodingKey {
        case codeName         = "CODENAME"
        case guName           = "GUNAME"
        case title            = "TITLE"
        case date             = "DATE"
        case place            = "PLACE"
        case orgName          = "ORG_NAME"
        case useTarget        = "USE_TRGT"
        case useFee           = "USE_FEE"
        case inquiry          = "INQUIRY"
        case player           = "PLAYER"
        case program          = "PROGRAM"
        case etcDesc          = "ETC_DESC"
        case orgLink          = "ORG_LINK"
        case mainImage        = "MAIN_IMG"
        case registrationDate = "RGSTDATE"
        case ticket           = "TICKET"
        case startDate        = "STRTDATE"
        case endDate          = "END_DATE"
        case themeCode        = "THEMECODE"
        case lot              = "LOT"
        case lat              = "LAT"
        case isFree           = "IS_FREE"
        case homepageAddr     = "HMPG_ADDR"
        case proTime          = "PRO_TIME"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        codeName         = (try? c.decodeIfPresent(String.self, forKey: .codeName))         ?? ""
        guName           = (try? c.decodeIfPresent(String.self, forKey: .guName))           ?? ""
        title            = (try? c.decodeIfPresent(String.self, forKey: .title))            ?? ""
        date             = (try? c.decodeIfPresent(String.self, forKey: .date))             ?? ""
        place            = (try? c.decodeIfPresent(String.self, forKey: .place))            ?? ""
        orgName          = (try? c.decodeIfPresent(String.self, forKey: .orgName))          ?? ""
        useTarget        = (try? c.decodeIfPresent(String.self, forKey: .useTarget))        ?? ""
        useFee           = (try? c.decodeIfPresent(String.self, forKey: .useFee))           ?? ""
        inquiry          = (try? c.decodeIfPresent(String.self, forKey: .inquiry))          ?? ""
        player           = (try? c.decodeIfPresent(String.self, forKey: .player))           ?? ""
        program          = (try? c.decodeIfPresent(String.self, forKey: .program))          ?? ""
        etcDesc          = (try? c.decodeIfPresent(String.self, forKey: .etcDesc))          ?? ""
        orgLink          = (try? c.decodeIfPresent(String.self, forKey: .orgLink))          ?? ""
        mainImage        = (try? c.decodeIfPresent(String.self, forKey: .mainImage))        ?? ""
        registrationDate = (try? c.decodeIfPresent(String.self, forKey: .registrationDate)) ?? ""
        ticket           = (try? c.decodeIfPresent(String.self, forKey: .ticket))           ?? ""
        startDate        = (try? c.decodeIfPresent(String.self, forKey: .startDate))        ?? ""
        endDate          = (try? c.decodeIfPresent(String.self, forKey: .endDate))          ?? ""
        themeCode        = (try? c.decodeIfPresent(String.self, forKey: .themeCode))        ?? ""
        lot              = (try? c.decodeIfPresent(String.self, forKey: .lot))              ?? ""
        lat              = (try? c.decodeIfPresent(String.self, forKey: .lat))              ?? ""
        isFree           = (try? c.decodeIfPresent(String.self, forKey: .isFree))           ?? ""
        homepageAddr     = (try? c.decodeIfPresent(String.self, forKey: .homepageAddr))     ?? ""
        proTime          = (try? c.decodeIfPresent(String.self, forKey: .proTime))          ?? ""
    }
}
