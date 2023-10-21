//
//  LoginService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import SoundCloud

protocol LoginService {
    func login() async throws
    func logout()
}

extension SoundCloud: LoginService {}
