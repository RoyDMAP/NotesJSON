//
//  Note+CoreDataClass.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.


import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import CoreData     // Brings in Apple's database system for storing data permanently

@objc(Note)         // Tells Objective-C runtime this class is called "Note" (needed for Core Data)
public class Note: NSManagedObject {    // Creates a Note class that inherits from NSManagedObject (Core Data's base class for database objects)
    
    // MARK: - Convenience Initializers
    convenience init(noteTitle: String, noteContent: String, context: NSManagedObjectContext) {    // Creates an easy way to make a new note with title and content
        self.init(context: context)                     // Calls the main initializer to create the note in the database
        self.setValue(noteTitle, forKey: "title")       // Sets the note's title using key-value coding
        self.setValue(noteContent, forKey: "content")   // Sets the note's content using key-value coding
        self.setValue(Date(), forKey: "timestamp")      // Sets the note's creation time to right now
    }
    
    convenience init(noteTitle: String, noteContent: String, noteTimestamp: Date, context: NSManagedObjectContext) {    // Creates an easy way to make a new note with custom timestamp
        self.init(context: context)                     // Calls the main initializer to create the note in the database
        self.setValue(noteTitle, forKey: "title")       // Sets the note's title using key-value coding
        self.setValue(noteContent, forKey: "content")   // Sets the note's content using key-value coding
        self.setValue(noteTimestamp, forKey: "timestamp")    // Sets the note's creation time to the provided date
    }
}

// MARK: - Identifiable Conformance
extension Note: Identifiable {    // Makes Note work with SwiftUI lists by giving each note a unique identifier
    
}

// MARK: - Helper Methods
extension Note {    // Adds helpful computed properties to make working with notes easier
    
    var displayTitle: String {    // Creates a property that always returns a title, even if the note's title is empty
        let titleValue = self.value(forKey: "title") as? String    // Gets the title from the database and converts it to String
        return titleValue?.isEmpty == false ? titleValue! : "Untitled"    // Returns the title if it exists and isn't empty, otherwise returns "Untitled"
    }
    
    var hasContent: Bool {    // Creates a property that checks if the note has any content
        let contentValue = self.value(forKey: "content") as? String    // Gets the content from the database and converts it to String
        return contentValue?.isEmpty == false    // Returns true if content exists and isn't empty, false otherwise
    }
    
    var formattedTimestamp: String {    // Creates a property that formats the timestamp into a readable string
        guard let timestampValue = self.value(forKey: "timestamp") as? Date else { return "" }    // Gets timestamp from database, returns empty string if no timestamp
        let formatter = DateFormatter()    // Creates a date formatter to convert Date to readable text
        formatter.dateStyle = .medium      // Sets date format to show month, day, year
        formatter.timeStyle = .short       // Sets time format to show hour and minute
        return formatter.string(from: timestampValue)    // Converts the date to a formatted string and returns it
    }
}

// MARK: - Preview Helper (for testing the Note class)
#if DEBUG    // This code only exists in debug builds, not in the final app
extension Note {    // Adds a helper method for creating test notes
    static func createPreviewNote(withTitle titleText: String, content contentText: String, hoursAgo: Int = 0, daysAgo: Int = 0, in context: NSManagedObjectContext) -> Note {    // Function to create sample notes for testing with custom timestamps
        let note = Note(context: context)    // Creates a new Note object in the database
        note.setValue(titleText, forKey: "title")     // Sets the note's title to the provided text
        note.setValue(contentText, forKey: "content") // Sets the note's content to the provided text
        
        var dateComponents = DateComponents()    // Creates an object to calculate custom dates
        dateComponents.hour = -hoursAgo         // Sets how many hours ago (negative goes backward in time)
        dateComponents.day = -daysAgo           // Sets how many days ago (negative goes backward in time)
        let calculatedDate = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()    // Calculates the final date by going backward from now
        note.setValue(calculatedDate, forKey: "timestamp")    // Sets the note's timestamp to the calculated date
        
        return note    // Returns the completed test note
    }
}
#endif
