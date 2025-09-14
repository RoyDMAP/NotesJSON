//
//  PreviewHelpers.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import CoreData

// MARK: - Preview Container for Core Data
class PreviewContainer {
    static let shared = PreviewContainer()
    
    lazy var container: NSPersistentContainer = {
        // IMPORTANT: Replace "YourDataModel" with your actual .xcdatamodeld file name
        let container = NSPersistentContainer(name: "YourDataModel")
        
        // Use in-memory store for previews
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Preview Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
}

// MARK: - Helper for Creating Sample Notes
func createSampleNote(withTitle titleText: String, content contentText: String, hoursAgo: Int = 0, daysAgo: Int = 0) -> Note {
    let context = PreviewContainer.shared.context
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
