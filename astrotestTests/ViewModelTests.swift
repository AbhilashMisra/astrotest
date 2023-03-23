//
//  ViewModelTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 23/03/23.
//

import XCTest
@testable import astrotest

final class ViewModelTests: XCTestCase {
    
    func test_fetchPreviousDateData_success() async {
        let guc = GUC(fact: .success(FactDataObject(copyright: "c1", date: Date.now, explanation: "e1", title: "t1", url: "u1", name: "n1")))
        let duc = DUC()
        let vm = AstroViewModel(getUsecase: guc, downloadUsecase: duc)
        
        await vm.fetchPreviousDateData()
        
        XCTAssertEqual(vm.data.value.count, 1)
        XCTAssertEqual(vm.data.value[0].title, "t1")
        XCTAssertEqual(vm.data.value[0].url, "u1")
        
    }
    
    func test_fetchPreviousDateData_getFailed() async {
        let guc = GUC(fact: .failure(.apiFailed))
        let duc = DUC()
        let vm = AstroViewModel(getUsecase: guc, downloadUsecase: duc)
        
        await vm.fetchPreviousDateData()
        
        XCTAssertEqual(vm.data.value.count, 0)
    }

}

private struct GUC: GetFactUseCase {
    var fact: Result<FactDataObject, AstroError>
    func getFactOn(date: Date) async throws -> astrotest.FactDataObject {
        switch fact {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
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

private class DUC: ImageFetchUseCase {
    var url: String?
    var isImageDownloaded = false
    
    func downloadImageFor(fact: astrotest.FactDataObject) async throws {
        url = fact.url
    }
    
    func isImageDownloadedFor(fact: astrotest.FactDataObject) -> Bool {
        return isImageDownloaded
    }
    
}
