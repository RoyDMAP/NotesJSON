//
//  Notes.JSONDemoApp.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI
import CoreData
import Foundation

@main
struct NotesJSONDemoApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NotesView_WithExportImport()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Preview
#Preview {
    NotesView_WithExportImport()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
