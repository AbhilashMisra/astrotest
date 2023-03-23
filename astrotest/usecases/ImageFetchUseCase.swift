//
//  ImageFetchUseCase.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

protocol ImageFetchUseCase {
    /// gets the image for fact
    /// - Parameter fact: date for which fact is required
    func downloadImageFor(fact: FactDataObject) async throws
    
    /// is the image already downloaded for fact
    /// - Parameter fact: fact object
    /// - Returns: true if image already downloaded
    func isImageDownloadedFor(fact: FactDataObject) -> Bool
}

struct ImageFetchUseCaseImplementation: ImageFetchUseCase {
    let fetcher: FactFetchable
    
    /// gets the image for fact
    /// - Parameter fact: date for which fact is required
    func downloadImageFor(fact: FactDataObject) async throws {
        return try await fetcher.downloadImageFor(fact: fact)
    }
    
    /// is the image already downloaded for fact
    /// - Parameter fact: fact object
    /// - Returns: true if image already downloaded
    func isImageDownloadedFor(fact: FactDataObject) -> Bool {
        return fetcher.isImageDownloadedFor(fact: fact)
    }
}
