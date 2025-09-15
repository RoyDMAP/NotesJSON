//
//  Persistence.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import CoreData     // Brings in Apple's database system for storing data permanently

struct PersistenceController {    // Creates a class to manage the Core Data database setup and operations
    static let shared = PersistenceController()    // Creates a single shared instance that the entire app can use

    static var preview: PersistenceController = {    // Creates a special version for SwiftUI previews with sample data
        let result = PersistenceController(inMemory: true)    // Creates a temporary database in memory (not saved to disk)
        let viewContext = result.container.viewContext       // Gets access to the database context for adding sample data
        
        // Create sample data for previews
        let sampleNote = Note(context: viewContext)    // Creates a new sample note in the preview database
        sampleNote.title = "Sample Note"              // Sets the sample note's title
        sampleNote.content = "This is a sample note for preview purposes."    // Sets the sample note's content
        sampleNote.timestamp = Date()                 // Sets the sample note's timestamp to current date/time
        
        do {                        // Tries to save the sample data
            try viewContext.save()  // Saves the sample note to the preview database
        } catch {                   // If saving fails
            let nsError = error as NSError    // Converts the error to a more detailed format
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")    // Crashes the app with error details (for debugging)
        }
        return result    // Returns the preview database controller with sample data
    }()

    let container: NSPersistentContainer    // Stores the main Core Data container that manages the database

    init(inMemory: Bool = false) {    // Initializer that sets up the database, with option for memory-only storage
        // FIXED: Using "Model" to match Model.xcdatamodeld
        container = NSPersistentContainer(name: "Model")    // Creates database container using your "Model.xcdatamodeld" file
        
        if inMemory {    // If this is for testing/previews (temporary storage)
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")    // Sets database to not save to disk (goes to nowhere)
        }
        
        container.loadPersistentStores(completionHandler: { _, error in    // Attempts to load/create the database files
            if let error = error as NSError? {    // If loading the database fails
                fatalError("Unresolved error \(error), \(error.userInfo)")    // Crashes the app with error details (for debugging)
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true    // Makes database automatically update when changes happen from other sources
    }
    
    func save() {    // Function to manually save any pending changes to the database
        let context = container.viewContext    // Gets the main database context

        if context.hasChanges {    // Only saves if there are actually changes to save (for efficiency)
            do {                   // Tries to save the changes
                try context.save() // Writes all pending changes to the database
            } catch {              // If saving fails
                let nsError = error as NSError    // Converts error to detailed format
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")    // Crashes the app with error details (for debugging)
            }
        }
    }
}
