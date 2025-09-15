//
//  PreviewHelpers.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import CoreData     // Brings in Apple's database system for storing data permanently

// MARK: - Preview Container for Core Data
class PreviewContainer {    // Creates a class to handle database setup for SwiftUI previews and testing
    static let shared = PreviewContainer()    // Creates a single shared instance that can be used throughout the app
    
    lazy var container: NSPersistentContainer = {    // Creates the database container only when first accessed (lazy loading)
        // FIXED: Using "Model" to match Model.xcdatamodeld
        let container = NSPersistentContainer(name: "Model")    // Creates database container using your "Model.xcdatamodeld" file
        
        // Use in-memory store for previews
        let description = NSPersistentStoreDescription()    // Creates configuration for how database should be stored
        description.type = NSInMemoryStoreType              // Sets database to use RAM instead of disk (temporary storage)
        description.shouldAddStoreAsynchronously = false    // Makes database load immediately instead of in background
        container.persistentStoreDescriptions = [description]    // Applies this configuration to the container
        
        container.loadPersistentStores { _, error in    // Attempts to set up and start the database
            if let error = error {                      // If setting up the database fails
                print("Preview Core Data error: \(error)")    // Prints error message to console for debugging
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true    // Makes the database automatically update when changes happen
        return container    // Returns the fully configured database container
    }()
    
    var context: NSManagedObjectContext {    // Provides easy access to the database context for saving/loading data
        container.viewContext                // Returns the main database context from the container
    }
    
    // Create empty container for testing
    static func createEmpty() -> PreviewContainer {    // Creates a fresh empty database container for testing
        let preview = PreviewContainer()               // Creates a new instance
        return preview                                 // Returns the empty container
    }
}

// MARK: - Helper for Creating Sample Notes
func createSampleNote(withTitle titleText: String, content contentText: String, hoursAgo: Int = 0, daysAgo: Int = 0) -> Note {    // Function to create test notes with custom titles, content, and timestamps
    let context = PreviewContainer.shared.context    // Gets access to the preview database
    let note = Note(context: context)                // Creates a new Note object in the database
    
    // Use generated properties instead of setValue
    note.title = titleText                                      // Sets the note's title to the provided text
    note.content = contentText.isEmpty ? nil : contentText     // Sets content to provided text, or nil if empty
    
    var dateComponents = DateComponents()    // Creates an object to calculate custom dates
    dateComponents.hour = -hoursAgo         // Sets how many hours ago (negative number goes backward in time)
    dateComponents.day = -daysAgo           // Sets how many days ago (negative number goes backward in time)
    let calculatedDate = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()    // Calculates the final date by subtracting time from now
    note.timestamp = calculatedDate         // Sets the note's creation time to the calculated date
    
    return note    // Returns the completed sample note
}
