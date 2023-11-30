//
//  AuthService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import SoundCloud

protocol AuthService {
    var tokens: TokenResponse? { get }
    func login() async throws
    func logout()
}

extension SoundCloud: AuthService {}
