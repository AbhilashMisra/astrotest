//
//  DatabaseConnector.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation
import CoreData

protocol DatabaseConnectable {
    /// Get fact from local Database for given date
    /// - Parameter date: date to get fact for
    /// - Returns: managed object if found
    func getFactFor(date: Date) -> FactData?
    /// Get fact from local Database before the given date
    /// - Parameter date: date to get fact for
    /// - Returns: managed object if found
    func getFactBefore(date: Date) -> FactData?
    /// Save the managed object for fact
    /// - Parameter fact: fact object to save
    func saveFact(fact: Fact)
}

struct DatabaseConnector: DatabaseConnectable {
    /// Managed object to fetch on, Default can be coredata context
    private let managedContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext = CoredataManager.shared.getContext) {
        self.managedContext = managedContext
    }
    
    /// Get fact from local Database for given date
    /// - Parameter date: date to get fact for
    /// - Returns: managed object if found
    func getFactFor(date: Date) -> FactData? {
        let request = NSFetchRequest<FactData>(entityName: "FactData")
        request.predicate = NSPredicate(format: "date == %@", date as CVarArg)
        let list = getList(request: request)
        return list?.first
    }
    
    /// Get fact from local Database before the given date
    /// - Parameter date: date to get fact for
    /// - Returns: managed object if found
    func getFactBefore(date: Date) -> FactData? {
        let request = NSFetchRequest<FactData>(entityName: "FactData")
        request.predicate = NSPredicate(format: "date <= %@", date as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let list = getList(request: request)
        return list?.first
    }
    
    /// Save the managed object for fact
    /// - Parameter fact: fact object to save
    func saveFact(fact: Fact) {
        let json: [String: Any] = ["date": fact.date, "title": fact.title, "explanation": fact.explanation, "url": fact.url, "copyright": fact.copyright, "name": fact.url.split(separator: "/").last]
        save(entity: FactData.entity(), json: [json])
    }
    
    /// get list for data from coredata
    /// - Parameter request: fetched request to perform
    /// - Returns: returning array of managed object
    private func getList<T:NSManagedObject>(request: NSFetchRequest<T>) -> [T]? {
          do {
            return try managedContext.fetch(request)
          } catch {
            print("Could not fetch. \(error)")
          }
        return nil
    }
    
    /// saving the data into coredata
    /// - Parameters:
    ///   - entity: managed object entity to use
    ///   - json: json to update the table
    private func save(entity: NSEntityDescription, json: [[String: Any]]) {
        
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let insertRequest = NSBatchInsertRequest(entity: entity, objects: json)
        do {
            try managedContext.execute(insertRequest)
        } catch {
            print("Could not save. \(error)")
        }
    }
}
