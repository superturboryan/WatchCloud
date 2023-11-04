//
//  MockDAO.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-01.
//

import SoundCloud
import Foundation

final class MockDAO<T: Codable>: DAO {

    var valueToReturn: T?
    var shouldThrowError = false
    var codingKey = "123"
    
    func get() throws -> T {
        guard let valueToReturn, !shouldThrowError else {
            throw MockError.mock
        }
        return valueToReturn
    }
    
    func save(_ value: T) throws {
        if shouldThrowError {
            throw MockError.mock
        }
        valueToReturn = value
    }
    
    func delete() throws {
        if shouldThrowError {
            throw MockError.mock
        }
        valueToReturn = nil
    }
}
