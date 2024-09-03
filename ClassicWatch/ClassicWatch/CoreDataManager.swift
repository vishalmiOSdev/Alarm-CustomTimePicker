//
//  Persistence.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 02/09/24.
//

import Foundation
import CoreData


final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "AlarmModel") 
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    func fetchAlarms() -> [AlarmList] {
        let fetchRequest: NSFetchRequest<AlarmList> = AlarmList.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching alarms: \(error)")
            return []
        }
    }
    
    func addAlarm(time: String, label: String, isActive: Bool, date: Date?, day: String?) {
        let newAlarm = AlarmList(context: persistentContainer.viewContext)
        newAlarm.id = UUID()
        newAlarm.day = day
        newAlarm.date = date
        newAlarm.alarmDiscription = label
        newAlarm.isActiveAlarm = isActive
        
        // Save hours and minutes
        if let timeComponents = time.split(separator: ":").map(String.init) as [String]? {
            newAlarm.hours = Int16(timeComponents[0]) ?? 0
            newAlarm.minutes = Int16(timeComponents[1].prefix(2)) ?? 0
        }
        
        saveContext()
    }

    func updateAlarm(alarm: AlarmList, time: String, label: String, isActive: Bool, date: Date?, day: String?) {
        alarm.day = day
        alarm.date = date
        alarm.alarmDiscription = label
        alarm.isActiveAlarm = isActive
        
        // Update hours and minutes
        if let timeComponents = time.split(separator: ":").map(String.init) as [String]? {
            alarm.hours = Int16(timeComponents[0]) ?? 0
            alarm.minutes = Int16(timeComponents[1].prefix(2)) ?? 0
        }
        
        saveContext()
    }

    
    func deleteAlarm(alarm: AlarmList) {
        persistentContainer.viewContext.delete(alarm)
        saveContext()
    }
}
