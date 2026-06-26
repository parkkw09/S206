//
//  NewCultureEvent.swift
//  S206
//
//  도메인 모델. 외부 의존성(Codable, JSON 키) 없이 순수 Swift 타입만 사용합니다.
//

import Foundation

struct CulturalEvent {
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
}
