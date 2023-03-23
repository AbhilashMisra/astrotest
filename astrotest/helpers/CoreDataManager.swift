//
//  CoreDataManager.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

import CoreData


final class CoredataManager {
    private init(){}
    static let shared = CoredataManager()
    
    /// Creates a new context to be used on non-main thread
    lazy var getContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "astrotest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        return container
    }()
}
