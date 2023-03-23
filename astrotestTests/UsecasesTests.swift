//
//  astrotestTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 22/03/23.
//

import XCTest
@testable import astrotest

final class UsecasesTests: XCTestCase {

    func test_getUseCase_getFact_Success() async {
        let fetcher = MockFetcher()
        fetcher.fact = .success(FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
        let gc = GetFactUseCaseImplementation(fetcher: fetcher)
        
        do {
            let fact = try await gc.getFactOn(date: Date.now)
            XCTAssertEqual(fact.title, "T1")
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_getUseCase_getFact_Failed() async {
        let fetcher = MockFetcher()
        fetcher.fact = .failure(.apiFailed)
        let gc = GetFactUseCaseImplementation(fetcher: fetcher)
        
        do {
            _ = try await gc.getFactOn(date: Date.now)
            XCTFail("Shouldn't come here")
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, AstroError.apiFailed)
        }
    }
    
    func test_downloadUseCase_download_success() async {
        let fetcher = MockFetcher()
        let dc = ImageFetchUseCaseImplementation(fetcher: fetcher)
        
        do {
            try await dc.downloadImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
            XCTAssertEqual(fetcher.download, "U1")
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_downloadUseCase_isDownloaded_success() async {
        let fetcher = MockFetcher()
        fetcher.isImageDownloading = true
        let dc = ImageFetchUseCaseImplementation(fetcher: fetcher)
        
        let isD = dc.isImageDownloadedFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
        
        XCTAssertTrue(isD)
    }
    
    func test_downloadUseCase_isDownloaded_failed() async {
        let fetcher = MockFetcher()
        fetcher.isImageDownloading = false
        let dc = ImageFetchUseCaseImplementation(fetcher: fetcher)
        
        let isD = dc.isImageDownloadedFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
        
        XCTAssertFalse(isD)
    }
    
    func test_getUseCase_getNext_Success() async {
        let fetcher = MockFetcher()
        fetcher.fact = .success(FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
        let gc = GetFactUseCaseImplementation(fetcher: fetcher)
        
        let fact = gc.getNextLocalFactAfter(date: Date.now)
        XCTAssertNotNil(fact)
        XCTAssertEqual(fact!.title, "T1")
        
    }
    
    func test_getUseCase_getNext_Failed() async {
        let fetcher = MockFetcher()
        let gc = GetFactUseCaseImplementation(fetcher: fetcher)
        
        let fact = gc.getNextLocalFactAfter(date: Date.now)
        XCTAssertNil(fact)
    }
}

private class MockFetcher: FactFetchable {
    var fact: Result<FactDataObject, AstroError>?
    var download: String?
    var isImageDownloading: Bool = false
    
    func getFact(date: Date) async throws -> astrotest.FactDataObject {
        switch fact {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            throw AstroError.apiFailed
        }
    }
    
    func downloadImageFor(fact: astrotest.FactDataObject) async throws {
        download = fact.url
    }
    
    func stopDownloadImageFor(fact: astrotest.FactDataObject) async throws {
        // stopped downloading
    }
    
    func isImageDownloadedFor(fact: astrotest.FactDataObject) -> Bool {
        return isImageDownloading
    }
    
    func getNextLocalFactAfter(date: Date) -> FactDataObject? {
        switch fact {
        case .success(let success):
            return success
        default:
            return nil
        }
    }
}
