//
//  SeoulUsecase.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/29.
//

import Foundation

protocol SeoulUsecase {
    func getCultureInfo() async throws -> Response<NewCultureEvent>
}
