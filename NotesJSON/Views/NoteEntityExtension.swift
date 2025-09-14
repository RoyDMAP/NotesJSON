//
//  NoteEntityExtension.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import CoreData

// MARK: - Note Entity Extension (if not auto-generated)
extension Note {
    static func create(in context: NSManagedObjectContext, title: String, content: String, timestamp: Date = Date()) -> Note {
        let note = Note(context: context)
        note.title = title
        note.content = content
        note.timestamp = timestamp
        return note
    }
}
