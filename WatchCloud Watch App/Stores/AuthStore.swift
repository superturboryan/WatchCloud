//
//  AuthStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation
import SoundCloud

final class AuthStore: ObservableObject {
    
    /// Initial state is `true` to prevent `LoginView` from appearing on every app launch
    @Published public var isLoggedIn: Bool = true
    
    private let service: AuthService
    
    init(
        _ service: AuthService,
        isLoggedIn: Bool = true
    ) {
        self.service = service
        self.isLoggedIn = isLoggedIn
    }
}

extension AuthStore {
    
    @discardableResult
    @MainActor
    func login() async throws -> TokenResponse {
        do {
            let tokens = try await service.login()
            isLoggedIn = true
            return tokens
        } catch SoundCloud.Error.cancelledLogin {
            isLoggedIn = false
            throw Error.cancelledLogin
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
        case cancelledLogin
        case loggingIn
        
        var errorDescription: String? {
            switch self {
            case .cancelledLogin: "Connecting to SoundCloud was cancelled."
            case .loggingIn: String(localized: "There was a problem connecting to SoundCloud. Verify your account works on soundcloud.com or try one of the other login methods")
            }
        }
    }
}
