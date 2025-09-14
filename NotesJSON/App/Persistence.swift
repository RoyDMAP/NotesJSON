//
//  Persistence.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import CoreData
import Foundation
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Preview instance for SwiftUI previews with sample data
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample notes using a helper function to avoid ambiguity
        createSampleNotes(in: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure store description
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Enable automatic merging of changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Set merge policy to handle conflicts
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// MARK: - Helper Functions
private func createSampleNotes(in context: NSManagedObjectContext) {
    let sampleData = [
        ("Meeting Notes", "Discussed project timeline, budget allocation, and team responsibilities.", 0),
        ("Shopping List", "Milk, Bread, Eggs, Butter, Cheese", -2),
        ("Important Reminder", "Call the dentist to schedule appointment", -24),
        ("Vacation Ideas", "Research flights to Japan, check hotel availability", -48),
        ("Book Notes", "Short note content", -72)  // ← Provide content since it's non-optional
    ]
    
    // Wait for Core Data to be ready before creating entities
    context.performAndWait {
        for (titleText, contentText, hoursOffset) in sampleData {
            // Create using NSEntityDescription for better compatibility
            guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {
                print("Warning: Could not find Note entity")
                continue
            }
            
            let note = NSManagedObject(entity: entity, insertInto: context)
            
            // Set all non-optional attributes
            note.setValue(titleText, forKey: "title")
            note.setValue(contentText, forKey: "content")  // Must have content since non-optional
            
            let timestamp = Calendar.current.date(byAdding: .hour, value: hoursOffset, to: Date()) ?? Date()
            note.setValue(timestamp, forKey: "timestamp")
        }
    }
}

// MARK: - Traditional Preview (Compatible with older iOS versions)
struct PersistenceController_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        Text("Core Data Preview Context Ready")
            .environment(\.managedObjectContext, context)
            .onAppear {
                // Test that sample data is loaded using NSEntityDescription
                let request = NSFetchRequest<NSManagedObject>(entityName: "Note")
                do {
                    let notes = try context.fetch(request)
                    print("Preview context loaded with \(notes.count) sample notes")
                } catch {
                    print("Error fetching preview notes: \(error)")
                }
            }
    }
}
