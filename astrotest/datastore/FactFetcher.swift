//
//  FactFetcher.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

struct FactDataObject {
    let copyright: String?
    let date: Date?
    let explanation: String?
    let title: String?
    let url: String?
    let name: String?
    
    var filePath: String? {
        get {
            if let name {
                let docdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                return docdir.appending(path: "images").appending(path: name).path()
            }
            return nil
        }
    }
}

protocol FactFetchable {
    /// get the fact value for given date
    /// - Parameter date: date for which fact is needed
    /// - Returns: fact object
    func getFact(date: Date) async throws -> FactDataObject
    
    /// gets the image for fact
    /// - Parameter fact: fact is required
    func downloadImageFor(fact: FactDataObject) async throws
    
    /// stops the image download for fact
    /// - Parameter fact: fact is required
    func stopDownloadImageFor(fact: FactDataObject) async throws
    
    /// is image downloaded for the fact
    /// - Parameter fact: fact to check for
    /// - Returns: true if image is already downloaded
    func isImageDownloadedFor(fact: FactDataObject) -> Bool
    
    /// Get next offline fact available
    /// - Parameter date: date to look after
    /// - Returns: fact object
    func getNextLocalFactAfter(date: Date) -> FactDataObject?
}

struct FactFetcher: FactFetchable {
    let apiConnector: ApiConnectable
    let databaseConnector: DatabaseConnectable
    let fileStoreConnector: FileStoreConnectable
    
    /// get the fact value for given date
    /// - Parameter date: date for which fact is needed
    /// - Returns: fact object
    func getFact(date: Date) async throws -> FactDataObject {
        if let fact = databaseConnector.getFactFor(date: date) {
            return getFactDataObject(fact: fact)
        } else {
            let factRes = try await apiConnector.getFactFor(date: date)
            databaseConnector.saveFact(fact: factRes)
            let fact = databaseConnector.getFactFor(date: date)
            return getFactDataObject(fact: fact!)
        }
    }
    
    /// Get next offline fact available
    /// - Parameter date: date to look after
    /// - Returns: fact object
    func getNextLocalFactAfter(date: Date) -> FactDataObject? {
        let fact = databaseConnector.getFactBefore(date: date)
        if let fact {
            return getFactDataObject(fact: fact)
        }
        return nil
    }
    
    private func getFactDataObject(fact: FactData) -> FactDataObject {
        return FactDataObject(copyright: fact.copyright, date: fact.date, explanation: fact.explanation, title: fact.title, url: fact.url, name: fact.name)
    }
    
    /// gets the image for fact
    /// - Parameter fact: fact is required
    func downloadImageFor(fact: FactDataObject) async throws {
        if !fileStoreConnector.isImageDownloaded(fact: fact),
           let urlStr = fact.url,
           let url = URL(string: urlStr),
           !apiConnector.isDownloadingImage(url: url) {
            let downloaded = try await apiConnector.downloadImageFrom(url: url)
            let _ = try fileStoreConnector.saveImageFor(fact: fact, from: downloaded)
        }
    }
    
    /// stops the image download for fact
    /// - Parameter fact: fact is required
    func stopDownloadImageFor(fact: FactDataObject) async throws {
        if let urlStr = fact.url,
           let url = URL(string: urlStr) {
            apiConnector.cancelImageDownload(url: url)
        }
    }
    
    /// is image downloaded for the fact
    /// - Parameter fact: fact to check for
    /// - Returns: true if image is already downloaded
    func isImageDownloadedFor(fact: FactDataObject) -> Bool {
        return fileStoreConnector.isImageDownloaded(fact: fact)
    }
}
