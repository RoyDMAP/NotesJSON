//
//  Note+CoreDataProperties.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.


import SwiftUI      // Brings in Apple's modern user interface framework
import Foundation   // Brings in basic Swift utilities like Date, String functions, etc.
import CoreData     // Brings in Apple's database system for storing data permanently

extension Note {    // Adds properties and methods to the existing Note class

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {    // Creates a function that helps retrieve notes from the database
        return NSFetchRequest<Note>(entityName: "Note")    // Returns a request object configured to fetch Note entities from the database
    }

    @NSManaged public var content: String?    // Creates a property for the note's main text content, can be nil (empty)
    @NSManaged public var timestamp: Date?    // Creates a property for when the note was created/modified, can be nil
    @NSManaged public var title: String?      // Creates a property for the note's title, can be nil (empty)

}
