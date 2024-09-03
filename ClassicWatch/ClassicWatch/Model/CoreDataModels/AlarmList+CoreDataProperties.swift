//
//  AlarmList+CoreDataProperties.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 02/09/24.
//
//

import Foundation
import CoreData


extension AlarmList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlarmList> {
        return NSFetchRequest<AlarmList>(entityName: "AlarmList")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var day: String?
    @NSManaged public var date: Date?
    @NSManaged public var alarmDiscription: String?
    @NSManaged public var isActiveAlarm: Bool
    @NSManaged public var hours: Int16  // New attribute
    @NSManaged public var minutes: Int16 // New attribute

}

extension AlarmList : Identifiable {

}
