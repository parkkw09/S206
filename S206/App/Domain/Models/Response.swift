//
//  Result.swift
//  S206
//
//  Created by 박관웅 [parkkw09] on 2022/08/29.
//

import Foundation

struct Response<T> {
    let count: Int
    let code: String
    let message: String
    let list: [T]
}
