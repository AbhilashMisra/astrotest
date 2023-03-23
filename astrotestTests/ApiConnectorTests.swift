//
//  ApiConnectorTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 23/03/23.
//

import XCTest
@testable import astrotest

final class ApiConnectorTests: XCTestCase {
    
    private let mockData = """
        {
            "copyright":"Robert Fedez",
            "date":"2023-03-19",
            "explanation":"To see the feathered serpent .",
            "hdurl":"https://apod.nasa.gov/apod/image/2303/MayanMilkyWay_Fernandez_1600.jpg",
            "media_type":"image",
            "service_version":"v1",
            "title":"Equinox at the Pyramid of the Feathered Serpent",
            "url":"https://apod.nasa.gov/apod/image/2303/MayanMilkyWay_Fernandez_1080.jpg"
        }
        """.data(using: .utf8)

    func test_getFactFor_success() async {
        let ms = MockSession()
        ms.data = mockData
        let api = ApiConnector(session: ms)
        
        let fact = try? await api.getFactFor(date: Date.now)
        
        XCTAssertNotNil(fact)
        XCTAssertEqual(fact!.title, "Equinox at the Pyramid of the Feathered Serpent")
    }
    
    func test_getFactFor_apiFailed() async {
        let ms = MockSession()
        ms.error = .apiFailed
        let api = ApiConnector(session: ms)
        
        do {
            _ = try await api.getFactFor(date: Date.now)
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, AstroError.apiFailed)
        }
    }
    
    func test_downloadImage_success() async {
        let ms = MockSession()
        ms.url = URL(string: "u1")
        let api = ApiConnector(session: ms)
        
        let url = try? await api.downloadImageFrom(url: URL(string:"u2")!)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.path, "u1")
    }
    
    func test_downloadImage_apiFailed() async {
        let ms = MockSession()
        ms.error = .apiFailed
        let api = ApiConnector(session: ms)
        
        do {
            _ = try await api.downloadImageFrom(url: URL(string:"u2")!)
            XCTFail("Shouldn't come here")
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, AstroError.apiFailed)
        }
    }
}

class MockSession: ApiHelper {
    var data: Data?
    var url: URL?
    var res: URLResponse?
    var error: AstroError?
    
    func get(url: URL, queryItems: [URLQueryItem]) async throws -> Data {
        if data != nil {
            return data!
        }
        throw error ?? .apiFailed
    }
    
    func download(url: URL, callback: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        callback(self.url, res, error)
        return MockSessionDownloadTask()
    }
    
}


class MockSessionDownloadTask: URLSessionDownloadTask {
    override init() {
    }
    
    override func resume() {
        
    }
}
