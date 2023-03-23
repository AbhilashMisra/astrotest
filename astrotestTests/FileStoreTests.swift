//
//  FileStoreTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 23/03/23.
//

import XCTest
@testable import astrotest

final class FileStoreTests: XCTestCase {

    func test_isImageDownloaded_success() {
        let mockFM = MockFileManager()
        let fs = FileStoreConnector(fileManager: mockFM)
        mockFM.fileExist = true
        
        let isD = fs.isImageDownloaded(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1"))
        
        XCTAssertTrue(isD)
        
    }
    
    func test_isImageDownloaded_notPresent() {
        let mockFM = MockFileManager()
        let fs = FileStoreConnector(fileManager: mockFM)
        mockFM.fileExist = false
        
        let isD = fs.isImageDownloaded(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1"))
        
        XCTAssertFalse(isD)
        
    }
    
    func test_saveImageFor_success() {
        let mockFM = MockFileManager()
        let fs = FileStoreConnector(fileManager: mockFM)
        mockFM.fileExist = false
        
        let isD = try? fs.saveImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1"), from: URL(string: "u2")!)
        
        XCTAssertNotNil(isD)
        XCTAssertEqual(isD!.path, "/doc/images/u1")
        
    }
    
    func test_saveImageFor_movingFailed() {
        let mockFM = MockFileManager()
        let fs = FileStoreConnector(fileManager: mockFM)
        mockFM.failure = AstroError.imageError
        
        do {
            let _ = try fs.saveImageFor(fact: FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1"), from: URL(string: "u2")!)
            
            XCTFail("Shouldn't come here")
        } catch {
            XCTAssertTrue(error is AstroError)
            XCTAssertEqual(error as! AstroError, .imageError)
        }
        
    }

}

private class MockFileManager: FileManager {
    var fileExist: Bool?
    var failure: AstroError?
    
    override func fileExists(atPath path: String) -> Bool {
        return fileExist ?? false
    }
    
    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [URL(string: "/doc")!]
    }
    
    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        // done
    }
    
    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        if failure != nil {
            throw failure!
        }
    }
}
