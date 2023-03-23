//
//  ApiConnector.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

protocol ApiConnectable {
    /// Get fact for the given date
    /// - Parameter date: date to get fact for
    /// - Returns: fact object
    func getFactFor(date: Date) async throws -> Fact
    /// Download image from the given url
    /// - Parameter url: url to download from
    /// - Returns: returns the downloaded to url
    func downloadImageFrom(url: URL) async throws -> URL
    /// Is the image currently being downloaded
    /// - Parameter url: url to check for download
    /// - Returns: true if image download in progress
    func isDownloadingImage(url: URL) -> Bool
    /// cancel the downloading image
    /// - Parameter url: url to cancel the download
    func cancelImageDownload(url: URL)
}

class ApiConnector: ApiConnectable {
    /// Api connection session. Default value can be UrlSession
    let session: ApiHelper
    /// Dictionary to story current downloading operations
    var downloadOperations: [URL : URLSessionDownloadTask]
    
    init(session: ApiHelper = URLSession.shared,
         downloadOperations: [URL : URLSessionDownloadTask] = [:]) {
        self.session = session
        self.downloadOperations = downloadOperations
    }
    
    /// Get fact for the given date
    /// - Parameter date: date to get fact for
    /// - Returns: fact object
    func getFactFor(date: Date) async throws -> Fact {
        if let url = URL(string: API_BASE_URL+ApiUrl.getFact.rawValue) {
            let data = try await session.get(url: url,
                           queryItems: [URLQueryItem(name: "date", value: date.getStringValue())])
            return try JSONDecoder().decode(Fact.self, from: data)
        } else {
            throw AstroError.malformedUrl
        }
    }
    
    /// Download image from the given url
    /// - Parameter url: url to download from
    /// - Returns: returns the downloaded to url
    func downloadImageFrom(url: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation({ promise in
            let res = session.download(url: url) {[weak self] downloadedUrl, _, err in
                self?.downloadOperations.removeValue(forKey: url)
                if let downloadedUrl {
                    promise.resume(returning: downloadedUrl)
                } else {
                    promise.resume(throwing: AstroError.apiFailed)
                }
            }
            downloadOperations[url] = res
            res.resume()
        })
    }
    
    /// Is the image currently being downloaded
    /// - Parameter url: url to check for download
    /// - Returns: true if image download in progress
    func isDownloadingImage(url: URL) -> Bool {
        return downloadOperations[url] != nil
    }
    
    /// cancel the downloading image
    /// - Parameter url: url to cancel the download
    func cancelImageDownload(url: URL) {
        downloadOperations[url]?.cancel()
    }
}
