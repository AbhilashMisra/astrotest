//
//  ApiConnectorTests.swift
//  astrotestTests
//
//  Created by Abhilash Mishra on 22/03/23.
//

import XCTest
import CoreData
@testable import astrotest

final class DbConnectorTests: XCTestCase {
    
    func test_getFact_NoData() {
        let db = DatabaseConnector(managedContext: StubCoreData().persistentContainer.newBackgroundContext())
        
        let data = db.getFactFor(date: Date.now)
        
        XCTAssertNil(data)
    }
    
    func test_getFact_OneData() {
        let context = StubCoreData().persistentContainer.newBackgroundContext()
        let db = DatabaseConnector(managedContext: context)
        let date = Date.now
        context.performAndWait {
            let req = NSBatchInsertRequest(entity: FactData.entity(), objects: [
                ["date": date, "title": "t1", "explanation": "e1", "url": "u1", "copyright": "c1", "name": "n1"]
            ])
            try! context.execute(req)
        }
        
        let data = db.getFactFor(date: date)
        
        XCTAssertNotNil(data)
    }
    
    func test_getFactBefore_NoData() {
        let db = DatabaseConnector(managedContext: StubCoreData().persistentContainer.newBackgroundContext())
        
        let data = db.getFactBefore(date: Date.now)
        
        XCTAssertNil(data)
    }
    
    func test_getFactBefore_OneData() {
        let context = StubCoreData().persistentContainer.newBackgroundContext()
        let db = DatabaseConnector(managedContext: context)
        let date = Date.now
        context.performAndWait {
            let req = NSBatchInsertRequest(entity: FactData.entity(), objects: [
                ["date": date, "title": "t1", "explanation": "e1", "url": "u1", "copyright": "c1", "name": "n1"]
            ])
            try! context.execute(req)
        }
        
        let data = db.getFactBefore(date: date)
        
        XCTAssertNotNil(data)
    }
    
    func test_storeFact_OneElement() {
        let context = StubCoreData().persistentContainer.newBackgroundContext()
        let db = DatabaseConnector(managedContext: context)
        let date = Date.now
        
        context.performAndWait {
            db.saveFact(fact: Fact(copyright: "c1", date: date, explanation: "e1", hdurl: "h1", mediaType: "m1", serviceVersion: "s1", title: "t1", url: "u1"))
        }
        
        let req = NSFetchRequest<FactData>.init(entityName: "FactData")
        let data = try? context.fetch(req)
        
        XCTAssertEqual(data?.count, 1)
    }

}

private class StubCoreData: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "astrotest")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
