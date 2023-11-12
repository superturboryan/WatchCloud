//
//  MockDAO.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-01.
//

import SoundCloud
import Foundation

final class MockDAO<T: Codable>: DAO {

    var persistedValue: T?
    var shouldThrowError = false
    var codingKey = "123"
    
    func get() throws -> T {
        guard let persistedValue, !shouldThrowError else {
            throw MockError.mock
        }
        return persistedValue
    }
    
    func save(_ value: T) throws {
        if shouldThrowError {
            throw MockError.mock
        }
        persistedValue = value
    }
    
    func delete() throws {
        if shouldThrowError {
            throw MockError.mock
        }
        persistedValue = nil
    }
}
