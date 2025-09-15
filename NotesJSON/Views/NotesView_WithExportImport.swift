//
//  NotesView_WithExportImport.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import SwiftUI      // Brings in Apple's modern user interface framework
import CoreData     // Brings in Apple's database system for storing data permanently

struct NotesView_WithExportImport: View {    // Creates a notes view that includes import and export functionality
    @Environment(\.managedObjectContext) private var viewContext    // Gets access to the app's database connection from the surrounding environment
    
    // FIXED: Use keyPath instead of key
    @FetchRequest(    // Automatically gets notes from the database and keeps them updated
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: false)],    // Orders notes by timestamp, newest first
        animation: .default    // Animates changes when notes are added/removed/updated
    ) private var notes: FetchedResults<Note>    // Creates a list of notes that stays synchronized with the database
    
    @State private var showingAddNote = false        // Controls whether the "add new note" screen is visible
    @State private var showingExportSheet = false   // Controls whether the file export dialog is visible
    @State private var showingImportSheet = false   // Controls whether the file import dialog is visible
    @State private var showingImportOptions = false // Controls whether the import options popup is visible
    @State private var exportDocument = JSONFile(data: Data())    // Stores the JSON file data for export
    @State private var alertMessage = ""            // Stores the message text to show in alert popups
    @State private var showingAlert = false         // Controls whether an alert popup is visible
    @State private var replaceOnImport = false      // Controls whether import should replace all notes or merge with existing
    @State private var selectedNote: Note?          // Stores which note is currently selected for editing
    @State private var showingEditNote = false      // Controls whether the edit note screen is visible
    
    var body: some View {    // Defines what this screen looks like visually
        NavigationView {     // Creates a screen with a navigation bar at the top
            Group {          // Groups the main content together
                if notes.isEmpty {    // If there are no notes in the database
                    EmptyNotesView()  // Shows the empty state view with helpful message
                } else {             // If there are notes to display
                    List {           // Creates a scrollable list container
                        ForEach(notes) { note in    // Goes through each note in the database and creates a row for it
                            NoteRowView(note: note)    // Shows each note using the custom NoteRowView component
                                .onTapGesture {        // When the user taps anywhere on this row
                                    selectedNote = note        // Sets this note as the one being edited
                                    showingEditNote = true     // Shows the edit screen
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {    // When user swipes left on the row
                                    Button("Delete", role: .destructive) {    // Creates a red "Delete" button
                                        deleteNote(note)                      // Calls function to delete this note
                                    }
                                    
                                    Button("Edit") {                          // Creates a blue "Edit" button
                                        selectedNote = note                   // Sets this note as the one being edited
                                        showingEditNote = true                // Shows the edit screen
                                    }
                                    .tint(.blue)                             // Makes the edit button blue
                                }
                        }
                        .onDelete(perform: deleteNotes)    // Enables standard iOS swipe-to-delete behavior
                    }
                }
            }
            .navigationTitle("Notes")    // Sets the screen title to "Notes"
            .toolbar {                   // Adds buttons to the navigation bar
                ToolbarItemGroup(placement: .navigationBarTrailing) {    // Groups items on the right side of navigation bar
                    Menu("Options", systemImage: "ellipsis.circle") {    // Creates a dropdown menu with three dots icon
                        Button("Export Notes", systemImage: "square.and.arrow.up") {    // Menu item to export notes
                            exportNotes()                                                // Calls the export function
                        }
                        .disabled(notes.isEmpty)    // Grays out the button if there are no notes to export
                        
                        Button("Import Notes", systemImage: "square.and.arrow.down") {    // Menu item to import notes
                            showingImportOptions = true                                   // Shows the import options popup
                        }
                        
                        Divider()    // Adds a visual separator line in the menu
                        
                        Button("Add Note", systemImage: "plus") {    // Menu item to add a new note
                            showingAddNote = true                    // Shows the add note screen
                        }
                    }
                    
                    Button("Add", systemImage: "plus") {    // Quick add button outside the menu
                        showingAddNote = true                // Shows the add note screen
                    }
                }
                
                if !notes.isEmpty {                                  // If there are notes in the list
                    ToolbarItem(placement: .navigationBarLeading) { // Places item on the left side of navigation bar
                        EditButton()                                 // Shows iOS standard "Edit" button for deleting multiple items
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {    // Shows a popup screen when showingAddNote becomes true
                AddNoteView()                         // The popup contains the "add new note" screen
            }
            .sheet(isPresented: $showingEditNote) {   // Shows a popup screen when showingEditNote becomes true
                if let selectedNote = selectedNote { // If a note is actually selected
                    EditNoteView(note: selectedNote) // The popup contains the "edit note" screen for the selected note
                }
            }
            .fileExporter(                           // Handles exporting files to the user's device
                isPresented: $showingExportSheet,   // Shows when showingExportSheet becomes true
                document: exportDocument,           // The file data to export
                contentType: .json,                 // Specifies this is a JSON file
                defaultFilename: "notes-export"     // Suggests this filename to the user
            ) { result in                           // When export is complete (success or failure)
                handleExportResult(result)          // Calls function to handle the result
            }
            .fileImporter(                          // Handles importing files from the user's device
                isPresented: $showingImportSheet,   // Shows when showingImportSheet becomes true
                allowedContentTypes: [.json],       // Only allows JSON files to be selected
                allowsMultipleSelection: false      // User can only select one file at a time
            ) { result in                           // When import is complete (success or failure)
                handleImportResult(result)          // Calls function to handle the result
            }
            .alert("Import Options", isPresented: $showingImportOptions) {    // Shows popup asking how to import
                Button("Replace All Notes") {       // Option to delete existing notes and replace with imported ones
                    replaceOnImport = true          // Sets flag to replace all notes
                    showingImportSheet = true       // Shows the file picker
                }
                
                Button("Merge with Existing") {     // Option to add imported notes to existing ones
                    replaceOnImport = false         // Sets flag to merge notes
                    showingImportSheet = true       // Shows the file picker
                }
                
                Button("Cancel", role: .cancel) { } // Option to cancel import
            } message: {                            // The message shown in the import options popup
                Text("Do you want to replace all existing notes or merge with existing notes?")
            }
            .alert("Message", isPresented: $showingAlert) {    // Shows general alert messages
                Button("OK") { }                                // Simple OK button to dismiss
            } message: {                                        // The message content
                Text(alertMessage)                              // Shows whatever text is stored in alertMessage
            }
        }
    }
    
    // MARK: - Export Functions
    private func exportNotes() {                    // Function that creates and exports a JSON file of all notes
        do {                                        // Tries to execute the export process
            let allNotes = try fetchAllNotes(viewContext)    // Gets all notes from the database
            guard !allNotes.isEmpty else {          // Checks if there are actually notes to export
                alertMessage = "No notes to export."        // Sets error message
                showingAlert = true                          // Shows the error popup
                return                                       // Stops the function here
            }
            
            let dtos = makeDTOs(from: allNotes)     // Converts notes to exportable format
            let encoder = JSONEncoder()             // Creates a JSON encoder
            encoder.dateEncodingStrategy = .iso8601 // Sets how dates should be formatted in JSON
            encoder.outputFormatting = .prettyPrinted    // Makes the JSON file readable with proper formatting
            let jsonData = try encoder.encode(dtos)      // Converts the notes to JSON data
            exportDocument = JSONFile(data: jsonData)    // Creates the file object for export
            showingExportSheet = true               // Shows the file export dialog
        } catch {                                   // If any step fails
            alertMessage = "Export failed: \(error.localizedDescription)"    // Creates user-friendly error message
            showingAlert = true                     // Shows the error popup
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {    // Function that handles what happens after export attempt
        switch result {                             // Checks if export succeeded or failed
        case .success(let url):                     // If export was successful
            alertMessage = "Notes exported successfully to: \(url.lastPathComponent)"    // Creates success message with filename
            showingAlert = true                     // Shows the success popup
        case .failure(let error):                   // If export failed
            alertMessage = "Export failed: \(error.localizedDescription)"    // Creates error message
            showingAlert = true                     // Shows the error popup
        }
    }
    
    // MARK: - Import Functions
    private func handleImportResult(_ result: Result<[URL], Error>) {    // Function that handles what happens after file selection for import
        switch result {                             // Checks if file selection succeeded or failed
        case .success(let urls):                    // If user successfully selected a file
            guard let url = urls.first else {       // Gets the first (and only) selected file
                alertMessage = "No file selected for import."    // Error if somehow no file was selected
                showingAlert = true                              // Shows error popup
                return                                           // Stops the function
            }
            performNotesImport(from: url)           // Calls function to actually import the file
        case .failure(let error):                   // If file selection failed
            alertMessage = "Import failed: \(error.localizedDescription)"    // Creates error message
            showingAlert = true                     // Shows error popup
        }
    }
    
    private func performNotesImport(from url: URL) {    // Function that actually imports notes from the selected file
        do {                                            // Tries to execute the import process
            try importNotes(from: url, into: viewContext, replace: replaceOnImport)    // Calls the import function with user's choice of replace/merge
            let action = replaceOnImport ? "replaced" : "merged"    // Creates appropriate success message text
            alertMessage = "Notes \(action) successfully!"         // Sets success message
            showingAlert = true                         // Shows success popup
        } catch {                                       // If import fails
            alertMessage = "Import failed: \(error.localizedDescription)"    // Creates error message
            showingAlert = true                         // Shows error popup
        }
    }
    
    // MARK: - Core Data Functions
    private func deleteNotes(offsets: IndexSet) {      // Function that deletes multiple notes (from swipe-to-delete)
        withAnimation {                                 // Makes the deletion animate smoothly
            offsets.map { notes[$0] }.forEach(viewContext.delete)    // Converts row numbers to actual notes and deletes each one
            
            do {                                        // Tries to save the changes
                try viewContext.save()                  // Saves changes to permanent storage
            } catch {                                   // If saving fails
                alertMessage = "Delete failed: \(error.localizedDescription)"    // Creates error message
                showingAlert = true                     // Shows error popup
            }
        }
    }
    
    private func deleteNote(_ note: Note) {             // Function that deletes a single note
        withAnimation {                                 // Makes the deletion animate smoothly
            viewContext.delete(note)                    // Removes the note from the database
            do {                                        // Tries to save the changes
                try viewContext.save()                  // Saves changes to permanent storage
            } catch {                                   // If saving fails
                alertMessage = "Delete failed: \(error.localizedDescription)"    // Creates error message
                showingAlert = true                     // Shows error popup
            }
        }
    }
}

// MARK: - Previews
#Preview("Notes with Data") {    // Creates a preview with sample notes for developers
    let context = PreviewContainer.shared.context    // Gets a test database context
    
    // Create sample data
    let _ = createSampleNote(withTitle: "Meeting Notes", content: "Project discussion")    // Creates first sample note
    let _ = createSampleNote(withTitle: "Shopping List", content: "Milk, Bread, Eggs")    // Creates second sample note
    
    return NotesView_WithExportImport()             // Shows the view
        .environment(\.managedObjectContext, context)    // Connects it to the test database
}

#Preview("Empty Notes") {        // Creates a preview with no notes to test empty state
    NotesView_WithExportImport() // Shows the view
        .environment(\.managedObjectContext, PreviewContainer.createEmpty().context)    // Uses empty test database
}

#Preview("Dark Mode") {          // Creates a preview in dark mode
    let context = PreviewContainer.shared.context    // Gets a test database context
    let _ = createSampleNote(withTitle: "Dark Mode Test", content: "Testing dark appearance")    // Creates sample note
    
    return NotesView_WithExportImport()             // Shows the view
        .environment(\.managedObjectContext, context)    // Connects to test database
        .preferredColorScheme(.dark)                      // Forces dark mode for this preview
}
