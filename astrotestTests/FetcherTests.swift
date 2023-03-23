//
//  FetcherTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 22/03/23.
//

import XCTest
@testable import astrotest

final class FetcherTests: XCTestCase {
    
    func test_getFact_ApiFail() async {
        let api = ApiConnectableMock(result: .failure(.apiFailed))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            let _ = try await fetcher.getFact(date: Date.now)
            XCTFail("Shouldn't come here")
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, .apiFailed)
        }
    }
    
    func test_getFact_ApiSuccess() async {
        let resp = """
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
        var api = ApiConnectableMock()
        api.result = .success(try! JSONDecoder().decode(Fact.self, from: resp!))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            let fact = try await fetcher.getFact(date: Date.now)
            XCTAssertEqual(fact.title, "Equinox at the Pyramid of the Feathered Serpent")
        } catch {
            print(error)
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_getFact_DBDataExists() async {
        let api = ApiConnectableMock(result: .failure(.apiFailed))
        let db = DBConnectableMock()
        db.factVal = StubFact(title: "T1", url: "U1")
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            let data = try await fetcher.getFact(date: Date.now)
            XCTAssertEqual(data.title, "T1")
            XCTAssertEqual(data.url, "U1")
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_getFactBefore_NoData() async {
        let api = ApiConnectableMock(result: .failure(.apiFailed))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        let data = fetcher.getNextLocalFactAfter(date: Date.now)
        XCTAssertNil(data)
            
    }
    
    func test_getFactBefore_DBDataExists() async {
        let api = ApiConnectableMock(result: .failure(.apiFailed))
        let db = DBConnectableMock()
        db.factVal = StubFact(title: "T1", url: "U1")
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        let data = fetcher.getNextLocalFactAfter(date: Date.now)
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.title, "T1")
        XCTAssertEqual(data!.url, "U1")
    }
    
    func test_downloadImageFor_ApiFail() async {
        let api = ApiConnectableMock(resultUrl: .failure(.apiFailed))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            let _ = try await fetcher.downloadImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
            XCTFail("Shouldn't come here")
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, .apiFailed)
        }
    }
    
    func test_downloadImageFor_imageAlreadyDownloaded() async {
        let api = ApiConnectableMock(resultUrl: .failure(.apiFailed))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        file.isImageDownloaded = true
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            try await fetcher.downloadImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_downloadImageFor_imageDownloadSuccess() async {
        let url = URL(string: "www.ab.com")!
        let api = ApiConnectableMock(resultUrl: .success(url))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            try await fetcher.downloadImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1"))
            XCTAssertEqual(file.savedImagePath, url)
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_stopDownloadImage_imageDownloadStopped() async {
        let url = URL(string: "www.ab.com")!
        let api = ApiConnectableMock(resultUrl: .success(url))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        do {
            let obj = FactDataObject(copyright: "c1", date: Date.now, explanation: "E1", title: "T1", url: "U1", name: "N1")
            Task {
                try await fetcher.downloadImageFor(fact: obj)
            }
            try await fetcher.stopDownloadImageFor(fact: obj)
            XCTAssertNotEqual(file.savedImagePath, url)
        } catch {
            XCTFail("Shouldn't come here")
        }
    }
    
    func test_dataObject_filePathGet() async {
        
        let fact = FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1")
        
        let url = fact.filePath
        
        XCTAssertTrue(url!.hasSuffix("/images/n1"))
    }
    
    func test_isImageDownloadedFor_imageDownloaded() async {
        let url = URL(string: "www.ab.com")!
        let api = ApiConnectableMock(resultUrl: .success(url))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        file.isImageDownloaded = true
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        let fact = FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1")
        let isD = fetcher.isImageDownloadedFor(fact: fact)
        
        XCTAssertTrue(isD)
    }
    
    func test_isImageDownloadedFor_imageNotDownloaded() async {
        let url = URL(string: "www.ab.com")!
        let api = ApiConnectableMock(resultUrl: .success(url))
        let db = DBConnectableMock()
        let file = FilestoreMock()
        file.isImageDownloaded = false
        let fetcher = FactFetcher(apiConnector: api, databaseConnector: db, fileStoreConnector: file)
        
        let fact = FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1")
        let isD = fetcher.isImageDownloadedFor(fact: fact)
        
        XCTAssertFalse(isD)
    }

}




private struct ApiConnectableMock: ApiConnectable {
    
    var result: Result<Fact, AstroError>?
    var resultUrl: Result<URL, AstroError>?
    var isDownloading = false
    var hold = false
    
    func getFactFor(date: Date) async throws -> Fact {
        if hold {
            try? await Task.sleep(for: .seconds(2))
        }
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            throw AstroError.malformedUrl
        }
    }
    
    func downloadImageFrom(url: URL) async throws -> URL {
        switch resultUrl {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        case .none:
            throw AstroError.malformedUrl
        }
    }
    
    func isDownloadingImage(url: URL) -> Bool {
        return isDownloading
    }
    
    func cancelImageDownload(url: URL) {
        // cancelled
    }
}

private class DBConnectableMock: DatabaseConnectable {
    
    
    var factVal: StubFact?
    
    func getFactFor(date: Date) -> astrotest.FactData? {
        return factVal
    }
    
    func saveFact(fact: astrotest.Fact) {
        factVal = StubFact(title: fact.title, url: fact.url)
    }
    func getFactBefore(date: Date) -> astrotest.FactData? {
        return factVal
    }
}

private class FilestoreMock: FileStoreConnectable {
    var isImageDownloaded = false
    var savedImagePath: URL?
    func isImageDownloaded(fact: astrotest.FactDataObject) -> Bool {
        return isImageDownloaded
    }
    
    func saveImageFor(fact: astrotest.FactDataObject, from path: URL) throws -> URL {
        savedImagePath = path
        return path
    }
}

private class StubFact: FactData {
    convenience init(title: String?, url: String?) {
        self.init()
        self.stubbedTitle = title
        self.stubbedUrl = url
    }

    var stubbedTitle: String?
    var stubbedUrl: String?
    var stubbedCopyright: String?
    var stubbedDate: Date?
    var stubbedExplaination: String?
    var stubbedName: String?
    override var title: String? {
        set {}
        get {
            return stubbedTitle
        }
    }
    override var url: String? {
        set {}
        get {
            return stubbedUrl
        }
    }
    override var copyright: String? {
        set {}
        get {
            return stubbedCopyright
        }
    }
    override var date: Date? {
        set {}
        get {
            return stubbedDate
        }
    }
    override var explanation: String? {
        set {}
        get {
            return stubbedExplaination
        }
    }
    override var name: String? {
        set {}
        get {
            return stubbedName
        }
    }
}
