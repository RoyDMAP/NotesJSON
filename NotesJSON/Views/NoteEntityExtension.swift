//
//  NoteEntityExtension.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import CoreData     // Brings in Apple's database system for storing data permanently

// MARK: - Note Entity Extension (if not auto-generated)
extension Note {    // Adds new functionality to the existing Note database object
    static func create(in context: NSManagedObjectContext, title: String, content: String, timestamp: Date = Date()) -> Note {    // Creates a function that makes new Note objects with given information, uses current date/time if no timestamp provided
        let note = Note(context: context)    // Creates a new Note object in the database
        note.title = title                   // Sets the note's title to the provided title text
        note.content = content               // Sets the note's content to the provided content text
        note.timestamp = timestamp           // Sets the note's timestamp to the provided date (or current date if none given)
        return note                          // Gives back the newly created note object
    }
}
