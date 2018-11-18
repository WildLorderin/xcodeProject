//
//  CoraDataHandler.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 17.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit
import CoreData

var reminder = [Reminder]()
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataHandler {
    
    class func getReminders() -> [Reminder] {
        return reminder
    }
    
    class func getContext() -> NSManagedObjectContext {
        return context
    }
    
    class func addReminder(title: String, latitude: Double, longitude: Double) {
        let reminder = Reminder(context: context)
        reminder.title = title
        reminder.latitude = latitude
        reminder.longitude = longitude
        
        print("reminder added")
        
        save(reminder: reminder)
        print("reminder saved")
    }
    
    class func save(reminder: Reminder) {
        do {
            try context.save()
            print("SAVED CALLED FORM FUNCTION SAVED()")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    class func load() {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        do {
            reminder = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    class func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
}
