//
//  AuthStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation
import SoundCloud

final class AuthStore: ObservableObject {
    
    @Published public private(set) var isLoggedIn: Bool = true
    
    // MARK: - Dependencies
    private let service: LoginService
    init(_ service: LoginService) {
        self.service = service
    }
}

extension AuthStore {
    func login() async throws {
        do {
            try await service.login()
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            await MainActor.run {
                isLoggedIn = false
            }
            throw error
        }
    }
    
    func logout() {
        service.logout()
        isLoggedIn = false
    }
}
