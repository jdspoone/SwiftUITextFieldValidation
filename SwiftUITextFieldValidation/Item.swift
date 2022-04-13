/*
    Item.swift
    SwiftUITextFieldValidation

    Created by Jeff Spooner on 2022-04-12.
*/

import CoreData


@objc(Item)
class Item: NSManagedObject, Identifiable
  {
    @NSManaged var name: String


    convenience init(name: String, context: NSManagedObjectContext)
      {
        let description = NSEntityDescription.entity(forEntityName: "Item", in: context)!

        self.init(entity: description, insertInto: context)

        self.name = name
      }
  }
