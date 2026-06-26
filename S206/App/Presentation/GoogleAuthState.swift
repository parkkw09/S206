//
//  GoogleAuthState.swift
//  S206
//
//  Google 인증 상태. mos 의 `sealed interface GoogleAuthState` 와 동일 구조입니다.
//

enum GoogleAuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case error(String)
}
