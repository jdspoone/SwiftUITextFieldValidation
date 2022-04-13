/*
    DataStore.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import CoreData


class DataStore
  {
    enum InitializationOption
      {
        case preview
        case resetStore
        case addSampleData
      }

    private let persistentContainer: NSPersistentContainer


    public var managedObjectContext: NSManagedObjectContext
      {
        persistentContainer.viewContext
      }


    init(options: [InitializationOption] = [])
      {
        self.persistentContainer = NSPersistentContainer(name: "Model")

        let storeDescription = persistentContainer.persistentStoreDescriptions.first!

        if options.contains(.resetStore) {
          if let storeURL = storeDescription.url {
            do { try FileManager.default.removeItem(at: storeURL) }
            catch { print("Failed to remove \(storeURL) with error: \(error)") }
          }
        }

        if options.contains(.preview) {
          storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { description, error in
          if let error = error {
            fatalError("Failed to load persistent store with error: \(error)")
          }
        }

        if options.contains(.addSampleData) {
          do {
            let _ =  [
              Item(name: "Sample Item A", context: managedObjectContext),
              Item(name: "Sample Item B", context: managedObjectContext)
            ]
            try managedObjectContext.save()
          }
          catch { fatalError("Failed to create and save sample data with error: \(error)") }
        }
      }

    var items: [Item]
      {
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.sortDescriptors = [.init(key: "name", ascending: true)]

        do { return try managedObjectContext.fetch(request) }
        catch { fatalError("\(error)") }
      }
  }
