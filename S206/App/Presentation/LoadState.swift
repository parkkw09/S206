//
//  LoadState.swift
//  S206
//
//  UI 로딩 상태. mos 의 `sealed interface LoadState` 와 동일한 구조입니다.
//

enum LoadState: Equatable {
    case idle
    case loading
    case loadingMore
    case success
    case error(String)
}
