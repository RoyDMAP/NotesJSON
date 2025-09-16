//
//  NoteListView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI    // Brings in Apple's user interface framework for building iOS apps
import CoreData   // Brings in Apple's database framework for storing data permanently on the device

struct NotesListView: View {    // Creates a new screen component called "NotesListView" that follows SwiftUI's View rules
    @Environment(\.managedObjectContext) private var viewContext    // Gets access to the app's database connection from the surrounding environment
    
    @FetchRequest(    // Automatically retrieves notes from the database and keeps them updated in real-time
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: false)],    // Orders notes by creation time, newest first
        animation: .default    // Smoothly animates changes when notes are added, removed, or updated
    ) private var notes: FetchedResults<Note>    // Creates a list of notes that stays synchronized with the database
    
    @State private var showingAddNote = false    // Controls whether the "create new note" screen is visible
    @State private var editingNote: Note?        // Stores which note is currently being edited (nil means no note is being edited)
    
    // Export/Import state variables - these control the import/export functionality
    @State private var showingExportSheet = false   // Controls whether the file save dialog is visible
    @State private var showingImportSheet = false   // Controls whether the file selection dialog is visible
    @State private var showingImportOptions = false // Controls whether the import choice popup is visible
    @State private var exportDocument = JSONFile(data: Data())    // Stores the file data that will be exported
    @State private var alertMessage = ""            // Stores the text to show in popup messages
    @State private var showingAlert = false         // Controls whether a popup message is visible
    @State private var replaceOnImport = false      // Controls whether import should replace all notes or add to existing ones
    
    var body: some View {    // Defines how this screen looks and behaves
        NavigationView {     // Creates a screen with a navigation bar at the top
            List {           // Creates a scrollable list container
                ForEach(notes) { note in    // Goes through each note in the database and creates a row for it
                    VStack(alignment: .leading, spacing: 4) {    // Arranges note information vertically, aligned to the left, with 4 points of space between items
                        HStack {    // Arranges title and date horizontally (side by side)
                            Text(note.title ?? "Untitled")    // Shows the note's title, or "Untitled" if no title exists
                                .font(.headline)       // Makes the text larger and bold like a headline
                                .fontWeight(.semibold) // Makes it semi-bold weight
                                .lineLimit(1)          // Limits title to one line, adding "..." if too long
                            
                            Spacer()    // Pushes the timestamp to the right side of the row
                            
                            if let timestamp = note.timestamp {    // If the note has a creation date
                                Text(timestamp, style: .date)     // Shows the date in a readable format like "Dec 15, 2024"
                                    .font(.caption)                // Makes it small text
                                    .foregroundStyle(.secondary)   // Makes it gray color
                            }
                        }
                        
                        if let content = note.content, !content.isEmpty {    // If the note has content text and it's not empty
                            Text(content)                                    // Shows the note's content
                                .font(.subheadline)                          // Makes it medium-sized text
                                .foregroundStyle(.secondary)                 // Makes it gray color
                                .lineLimit(2)                                // Limits content to 2 lines, adding "..." if longer
                        }
                    }
                    .padding(.vertical, 2)      // Adds 2 points of space above and below each note row
                    .contentShape(Rectangle())  // Makes the entire row area tappable, not just the text
                    .onTapGesture {             // When the user taps anywhere on this note row
                        editingNote = note      // Sets this note as the one to edit
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {    // When user swipes left on the row
                        Button("Delete", role: .destructive) {                // Creates a red "Delete" button
                            deleteNote(note)                                   // Calls function to delete this specific note
                        }
                    }
                }
                .onDelete(perform: deleteNotes)    // Enables standard iOS swipe-to-delete behavior for multiple selection
            }
            .navigationTitle("Notes")                   // Sets the screen title to "Notes"
            .navigationBarTitleDisplayMode(.large)     // Makes the title large at the top when scrolled up
            .toolbar {                                  // Adds buttons to the navigation bar
                ToolbarItemGroup(placement: .navigationBarTrailing) {    // Groups items on the right side of navigation bar
                    // Export/Import Menu
                    Menu("Options", systemImage: "ellipsis.circle") {    // Creates a dropdown menu with three dots icon
                        Button("Export Notes", systemImage: "square.and.arrow.up") {    // Menu item to save notes to a file
                            exportNotes()                                                // Calls the export function
                        }
                        .disabled(notes.isEmpty)    // Grays out the button if there are no notes to export
                        
                        Button("Import Notes", systemImage: "square.and.arrow.down") {    // Menu item to load notes from a file
                            showingImportOptions = true                                   // Shows the import choice popup
                        }
                        
                        Divider()    // Adds a visual separator line in the menu
                        
                        }
                    
                    // Quick Add Button - separate from the menu for easy access
                    Button {                    // Creates a standalone button
                        showingAddNote = true   // Shows the create note screen
                    } label: {                  // The button's appearance
                        Image(systemName: "square.and.pencil")    // Shows a compose/write icon
                    }
                }
                
                if !notes.isEmpty {                                  // If there are notes in the list
                    ToolbarItem(placement: .navigationBarLeading) { // Places item on the left side of navigation bar
                        EditButton()                                 // Shows iOS standard "Edit" button for bulk operations
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {    // Shows a popup screen when showingAddNote becomes true
                AddNoteView()                         // The popup contains the "create new note" screen
            }
            .sheet(item: $editingNote) { note in     // Shows a popup screen when editingNote has a value
                EditNoteView(note: note)             // The popup contains the "edit note" screen for the selected note
            }
            .fileExporter(                           // Handles saving files to the user's device
                isPresented: $showingExportSheet,   // Shows when showingExportSheet becomes true
                document: exportDocument,           // The file data to save
                contentType: .json,                 // Specifies this is a JSON file type
                defaultFilename: "notes-export"     // Suggests this filename to the user
            ) { result in                           // When export is complete (success or failure)
                handleExportResult(result)          // Calls function to handle the result and show feedback
            }
            .fileImporter(                          // Handles loading files from the user's device
                isPresented: $showingImportSheet,   // Shows when showingImportSheet becomes true
                allowedContentTypes: [.json],       // Only allows JSON files to be selected
                allowsMultipleSelection: false      // User can only select one file at a time
            ) { result in                           // When import file selection is complete
                handleImportResult(result)          // Calls function to process the selected file
            }
            .alert("Import Options", isPresented: $showingImportOptions) {    // Shows popup asking how to import
                Button("Replace All Notes") {       // Option to delete existing notes and replace with imported ones
                    replaceOnImport = true          // Sets flag to replace all notes
                    showingImportSheet = true       // Shows the file selection dialog
                }
                
                Button("Merge with Existing") {     // Option to add imported notes to existing ones without deleting
                    replaceOnImport = false         // Sets flag to merge notes
                    showingImportSheet = true       // Shows the file selection dialog
                }
                
                Button("Cancel", role: .cancel) { } // Option to cancel the import operation
            } message: {                            // The explanatory text shown in the import options popup
                Text("Do you want to replace all existing notes or merge with existing notes?")
            }
            .alert("Message", isPresented: $showingAlert) {    // Shows general notification messages
                Button("OK") { }                                // Simple OK button to dismiss the message
            } message: {                                        // The message content
                Text(alertMessage)                              // Shows whatever text is stored in alertMessage variable
            }
            .overlay {              // Overlays content on top of the list
                if notes.isEmpty {  // If there are no notes in the database
                    EmptyNotesView()    // Shows the empty state view with helpful message and icon
                }
            }
        }
    }
    
    // MARK: - Export Functions - these handle saving notes to files
    private func exportNotes() {                    // Function that creates and saves a file containing all notes
        do {                                        // Tries to execute the export process
            let allNotes = try fetchAllNotes(viewContext)    // Gets all notes from the database
            guard !allNotes.isEmpty else {          // Checks if there are actually notes to export
                alertMessage = "No notes to export."        // Sets error message text
                showingAlert = true                          // Shows the error popup
                return                                       // Stops the function here
            }
            
            let dtos = makeDTOs(from: allNotes)     // Converts notes to a format suitable for saving to file
            let encoder = JSONEncoder()             // Creates a JSON encoder to convert data to text format
            encoder.dateEncodingStrategy = .iso8601 // Sets how dates should be formatted in the file
            encoder.outputFormatting = .prettyPrinted    // Makes the file readable with proper formatting and spacing
            let jsonData = try encoder.encode(dtos)      // Converts the notes to JSON text data
            exportDocument = JSONFile(data: jsonData)    // Creates the file object ready for saving
            showingExportSheet = true               // Shows the file save dialog to the user
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
    
    // MARK: - Import Functions - these handle loading notes from files
    private func handleImportResult(_ result: Result<[URL], Error>) {    // Function that handles what happens after file selection for import
        switch result {                             // Checks if file selection succeeded or failed
        case .success(let urls):                    // If user successfully selected a file
            guard let url = urls.first else {       // Gets the first (and only) selected file
                alertMessage = "No file selected for import."    // Error if somehow no file was selected
                showingAlert = true                              // Shows error popup
                return                                           // Stops the function
            }
            performNotesImport(from: url)           // Calls function to actually read and process the file
        case .failure(let error):                   // If file selection failed or was cancelled
            alertMessage = "Import failed: \(error.localizedDescription)"    // Creates error message
            showingAlert = true                     // Shows error popup
        }
    }
    
    private func performNotesImport(from url: URL) {    // Function that actually reads notes from the selected file
        do {                                            // Tries to execute the import process
            try importNotes(from: url, into: viewContext, replace: replaceOnImport)    // Calls the import function with user's choice of replace/merge
            let action = replaceOnImport ? "replaced" : "merged"    // Creates appropriate success message text based on user choice
            alertMessage = "Notes \(action) successfully!"         // Sets success message
            showingAlert = true                         // Shows success popup
        } catch {                                       // If import fails (file corrupt, wrong format, etc.)
            alertMessage = "Import failed: \(error.localizedDescription)"    // Creates error message
            showingAlert = true                         // Shows error popup
        }
    }
    
    // MARK: - Core Data Functions - these handle database operations
    private func deleteNote(_ note: Note) {             // Function that removes a single note
        withAnimation {                                 // Makes the deletion animate smoothly
            viewContext.delete(note)                    // Removes the note from the database
            saveContext()                               // Saves the changes to permanent storage
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {       // Function that removes multiple notes (from Edit mode selection)
        withAnimation {                                 // Makes the deletion animate smoothly
            offsets.map { notes[$0] }.forEach(viewContext.delete)    // Converts row numbers to actual notes and deletes each one
            saveContext()                               // Saves the changes to permanent storage
        }
    }
    
    private func saveContext() {                        // Function that writes pending changes to the database permanently
        do {                                            // Tries to save the changes
            try viewContext.save()                      // Writes all pending changes to the database file
        } catch {                                       // If saving fails (disk full, permissions, etc.)
            alertMessage = "Save failed: \(error.localizedDescription)"    // Creates user-friendly error message
            showingAlert = true                         // Shows error popup to inform user
        }
    }
}

#Preview {    // Creates a preview for developers to see how the screen looks in Xcode
    NotesListView()    // Shows the notes list view
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)    // Connects it to a test database with sample data
}
