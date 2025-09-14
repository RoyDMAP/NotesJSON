//
//  Note+CoreDataProperties.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.


import SwiftUI
import Foundation
import CoreData

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?

}
