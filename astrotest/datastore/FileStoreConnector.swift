//
//  FileStoreConnector.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

protocol FileStoreConnectable {
    /// Is image downloaded for the Fact
    /// - Parameter fact: fact object to check
    /// - Returns: true if image is already downloaded
    func isImageDownloaded(fact: FactDataObject) -> Bool
    /// save image for the fact
    /// - Parameters:
    ///   - fact: fact to save image for
    ///   - path: path to save from
    /// - Returns: url fact image is saved on
    func saveImageFor(fact: FactDataObject, from path: URL) throws -> URL
}

class FileStoreConnector: FileStoreConnectable {
    
    let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    private lazy var directory: URL = {
        let docdir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docdir.appending(path: "images")
    }()
    
    /// Is image downloaded for the Fact
    /// - Parameter fact: fact object to check
    /// - Returns: true if image is already downloaded
    func isImageDownloaded(fact: FactDataObject) -> Bool {
        guard let urlStr = fact.url,
              let url = URL(string:urlStr) else {
            return false
        }
        let name = url.lastPathComponent
        return fileManager.fileExists(atPath: directory.path() + "/" + name)
    }
    
    /// save image for the fact
    /// - Parameters:
    ///   - fact: fact to save image for
    ///   - path: path to save from
    /// - Returns: url fact image is saved on
    func saveImageFor(fact: FactDataObject, from path: URL) throws -> URL {
        guard let urlStr = fact.url,
              let url = URL(string:urlStr) else {
            throw AstroError.malformedUrl
        }
        let name = url.lastPathComponent
        do {
            if !fileManager.fileExists(atPath: directory.path()) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            let newUrl = directory.appending(path: name)
            try fileManager.moveItem(at: path, to: newUrl)
            return newUrl
        } catch {
            throw AstroError.imageError
        }
    }
}
