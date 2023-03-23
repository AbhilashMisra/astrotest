//
//  ApiHelper.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

/// List of APIs required for application
enum ApiUrl: String {
    case getFact = "/planetary/apod"
}

/// Requirement for class or struct to be able to get data, default usage with URLSession
protocol ApiHelper: AnyObject {
    /// perform get request
    /// - Parameter url: url object for get request
    /// - Parameter queryItems: query items to pass
    /// - Returns: Data fetched by getting the given url
    func get(url: URL, queryItems: [URLQueryItem]) async throws -> Data
    
    /// perform download request
    /// - Parameter url: url to download from
    /// - Parameter callback: callback for response
    /// - Returns: download task
    func download(url: URL, callback:@escaping (URL?, URLResponse?, Error?) -> Void ) -> URLSessionDownloadTask
}
