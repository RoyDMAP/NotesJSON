//
//  Note+CoreDataClass.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.


import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    
    // MARK: - Convenience Initializers
    convenience init(noteTitle: String, noteContent: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.setValue(noteTitle, forKey: "title")
        self.setValue(noteContent, forKey: "content")
        self.setValue(Date(), forKey: "timestamp")
    }
    
    convenience init(noteTitle: String, noteContent: String, noteTimestamp: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        self.setValue(noteTitle, forKey: "title")
        self.setValue(noteContent, forKey: "content")
        self.setValue(noteTimestamp, forKey: "timestamp")
    }
}

// MARK: - Identifiable Conformance
extension Note: Identifiable {
    
}

// MARK: - Helper Methods
extension Note {
    
    var displayTitle: String {
        let titleValue = self.value(forKey: "title") as? String
        return titleValue?.isEmpty == false ? titleValue! : "Untitled"
    }
    
    var hasContent: Bool {
        let contentValue = self.value(forKey: "content") as? String
        return contentValue?.isEmpty == false
    }
    
    var formattedTimestamp: String {
        guard let timestampValue = self.value(forKey: "timestamp") as? Date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestampValue)
    }
}

// MARK: - Preview Helper (for testing the Note class)
#if DEBUG
extension Note {
    static func createPreviewNote(withTitle titleText: String, content contentText: String, hoursAgo: Int = 0, daysAgo: Int = 0, in context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.setValue(titleText, forKey: "title")
        note.setValue(contentText, forKey: "content")
        
        var dateComponents = DateComponents()
        dateComponents.hour = -hoursAgo
        dateComponents.day = -daysAgo
        let calculatedDate = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()
        note.setValue(calculatedDate, forKey: "timestamp")
        
        return note
    }
}
#endif
