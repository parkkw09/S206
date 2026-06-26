//
//  Response.swift
//  S206
//
//  페이지 단위 문화행사 조회 결과. 서버 코드/메시지는 Data 레이어에서 처리하므로 도메인 모델에서 제거합니다.
//

import Foundation

struct CulturalEventPage {
    let events: [CulturalEvent]
    let totalCount: Int
}
