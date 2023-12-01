//
//  AuthService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import SoundCloud

protocol AuthService {
    func login() async throws -> TokenResponse
    func logout()
}

extension SoundCloud: AuthService {}
