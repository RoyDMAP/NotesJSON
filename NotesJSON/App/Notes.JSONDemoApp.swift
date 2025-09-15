//
//  Notes.JSONDemoApp.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI      // Brings in Apple's modern user interface framework
import CoreData     // Brings in Apple's database system for storing data permanently
import Foundation   // Brings in basic Swift utilities like Date, String functions, etc.

@main               // Tells Swift this is the main entry point where the app starts running
struct NotesJSONDemoApp: App {    // Creates the main app structure that defines what the app does when it launches
    let persistenceController = PersistenceController.shared    // Creates the database controller for the entire app
    
    var body: some Scene {        // Defines what scenes (windows/screens) the app will show
        WindowGroup {             // Creates a group that can contain multiple windows (mainly for macOS, single window on iOS)
            NotesListView()       // Shows your actual notes list view instead of test text
                .environment(\.managedObjectContext, persistenceController.container.viewContext)    // Connects the view to the database
        }
    }
}

// MARK: - Preview
#Preview {    // Creates a preview that developers can see in Xcode without running the full app
    NotesListView()    // Shows the notes list view
        .environment(\.managedObjectContext, PreviewContainer.shared.context)    // Connects the preview to a test database
}
