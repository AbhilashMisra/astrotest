//
//  Extensions.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation


extension Date {
    /// get string value for date
    /// - Returns: date to convert
    func getStringValue() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
}

extension URLSession: ApiHelper {
    func get(url: URL, queryItems: [URLQueryItem]) async throws -> Data {
        var request = URLRequest(url: url.appending(queryItems: [
            URLQueryItem(name: "api_key", value: AstroApiKey)
        ]+queryItems))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let res = try? await data(for: request)
        if let data = res?.0 {
            return data
        } else {
            throw AstroError.apiFailed
        }
        
    }
    
    func download(url: URL, callback:@escaping (URL?, URLResponse?, Error?) -> Void ) -> URLSessionDownloadTask {
        let request = URLRequest(url: url)
        return downloadTask(with: request, completionHandler: callback)
    }
}
