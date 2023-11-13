//
//  AuthStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation

final class AuthStore: ObservableObject {
    
    /// Initial state is `true` to prevent `LoginView` from appearing on every app launch
    @Published public private(set) var isLoggedIn: Bool = true
    
    private let service: AuthService
    
    init(_ service: AuthService) {
        self.service = service
    }
}

extension AuthStore {
    var authHeader: [String : String] { get async throws {
        try await service.authenticatedHeader
    }}
    
    @MainActor
    func login() async throws {
        do {
            try await service.login()
            isLoggedIn = true
        } catch {
            isLoggedIn = false
            throw Error.loggingIn
        }
    }
    
    func logout() {
        service.logout()
        isLoggedIn = false
    }
}

extension AuthStore {
    enum Error: LocalizedError {
        case loggingIn
    }
}
