//
//  getFactUseCase.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

protocol GetFactUseCase {
    /// gets the fact on given date
    /// - Parameter date: date for which fact is required
    /// - Returns: fact
    func getFactOn(date: Date) async throws -> FactDataObject
    
    /// get next local date
    /// - Parameter date: date to look after
    /// - Returns: fact object
    func getNextLocalFactAfter(date: Date) -> FactDataObject?
}

struct GetFactUseCaseImplementation: GetFactUseCase {
    let fetcher: FactFetchable
    
    /// gets the fact on given date
    /// - Parameter date: date for which fact is required
    /// - Returns: fact
    func getFactOn(date: Date) async throws -> FactDataObject {
        return try await fetcher.getFact(date: date)
    }
    
    /// get next local date
    /// - Parameter date: date to look after
    /// - Returns: fact object
    func getNextLocalFactAfter(date: Date) -> FactDataObject? {
        return fetcher.getNextLocalFactAfter(date: date)
    }
}
