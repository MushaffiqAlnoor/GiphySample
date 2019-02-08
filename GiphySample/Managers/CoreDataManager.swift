//
//  CoreDataManager.swift
//  GiphySample
//
//  Created by techjini on 06/02/19.
//  Copyright © 2019 techjini. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    // MARK: - Core Data stack
    static let shared = CoreDataManager()
    lazy var context = persistentContainer.viewContext
    
    private init() {  }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GiphySample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func insert(_ gif: Gif) {
        guard let favorites = fetch(withGifID: gif.id) else {
            let newGif = Favorites.init(entity: Favorites.entity(), insertInto: context)
            newGif.createdDate = Date()
            newGif.gifID = gif.id
            saveContext()
            return
        }
        favorites.createdDate = Date()
        saveContext()
    }
    
    func delete(_ gif: Gif) {
        guard let favorites = fetch(withGifID: gif.id) else {
            return
        }
        context.delete(favorites)
        Utils.removeGifFromLocal(gif.id+".gif")
        saveContext()
    }
    
    func fetchAllGifs() -> [Gif] {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        var gifList: [Gif] = []
        do {
            let favoritesList =  try context.fetch(fetchRequest)
            for eachFavorite in favoritesList {
                guard let id = eachFavorite.gifID else {
                    continue
                }
                let newGif = Gif(id: id, url: nil, title: nil)
                gifList.append(newGif)
            }
            return gifList
        } catch {
            return []
        }
    }
    
    func fetch(withGifID gifId: String) -> Favorites? {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gifID == [cd]%@", gifId)
        var favorites: Favorites?
        do {
            favorites =  try context.fetch(fetchRequest).first
            return favorites
        } catch {
            return nil
        }
    }
    
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
