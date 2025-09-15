//
//  NoteListView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI    // Brings in Apple's modern user interface framework
import CoreData   // Brings in Apple's database system for storing data permanently

struct NotesListView: View {    // Creates a new screen that displays a list of notes
    @Environment(\.managedObjectContext) private var viewContext    // Gets access to the app's database connection from the surrounding environment
    
    @FetchRequest(    // Automatically gets notes from the database and keeps them updated
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: false)],    // Orders notes by timestamp, newest first
        animation: .default    // Animates changes when notes are added/removed/updated
    ) private var notes: FetchedResults<Note>    // Creates a list of notes that stays synchronized with the database
    
    @State private var showingAddNote = false    // Controls whether the "add new note" screen is visible
    @State private var editingNote: Note?        // Stores which note is being edited (nil means no note is being edited)
    
    var body: some View {    // Defines what this screen looks like visually
        NavigationView {     // Creates a screen with a navigation bar at the top
            List {           // Creates a scrollable list container
                ForEach(notes) { note in    // Goes through each note in the database and creates a row for it
                    VStack(alignment: .leading, spacing: 4) {    // Arranges note info vertically, aligned to the left, with 4 points spacing
                        HStack {    // Arranges title and date horizontally
                            Text(note.title ?? "")    // Shows the note's title (empty string if no title)
                                .font(.headline)       // Makes the text larger and bold like a headline
                                .fontWeight(.semibold) // Makes it semi-bold
                                .lineLimit(1)          // Limits title to one line only
                            
                            Spacer()    // Pushes the timestamp to the right side
                            
                            if let timestamp = note.timestamp {    // If the note has a timestamp
                                Text(timestamp, style: .date)     // Shows the date in a readable format
                                    .font(.caption)                // Makes it small text
                                    .foregroundStyle(.secondary)   // Makes it gray color
                            }
                        }
                        
                        if let content = note.content, !content.isEmpty {    // If the note has content and it's not empty
                            Text(content)                                    // Shows the note's content
                                .font(.subheadline)                          // Makes it medium-sized text
                                .foregroundStyle(.secondary)                 // Makes it gray color
                                .lineLimit(2)                                // Limits content to 2 lines maximum
                        }
                    }
                    .padding(.vertical, 2)      // Adds 2 points of space above and below each row
                    .contentShape(Rectangle())  // Makes the entire row area tappable (not just the text)
                    .onTapGesture {             // When the user taps anywhere on this row
                        print("Tapping note: \(note.title ?? "No title")")    // Sends debug message to console
                        editingNote = note      // Sets this note as the one being edited
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {    // When user swipes left on the row
                        Button("Delete", role: .destructive) {                // Creates a red "Delete" button
                            deleteNote(note)                                   // Calls function to delete this note
                        }
                    }
                }
                .onDelete(perform: deleteNotes)    // Enables standard iOS swipe-to-delete behavior
            }
            .navigationTitle("Notes")                   // Sets the screen title to "Notes"
            .navigationBarTitleDisplayMode(.large)     // Makes the title large at the top
            .toolbar {                                  // Adds buttons to the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {    // Places item on the right side of navigation bar
                    Button {                                         // Creates a button
                        showingAddNote = true                        // When tapped, shows the "add note" screen
                    } label: {                                       // The button's appearance
                        Image(systemName: "square.and.pencil")      // Shows Apple's compose/write icon
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
            .sheet(item: $editingNote) { note in     // Shows a popup screen when editingNote has a value
                EditNoteView(note: note)             // The popup contains the "edit note" screen for the selected note
            }
            .overlay {                               // Overlays content on top of the list
                if notes.isEmpty {                   // If there are no notes in the database
                    VStack(spacing: 16) {            // Arranges empty state elements vertically with 16 points spacing
                        Image(systemName: "note.text")     // Shows Apple's note icon
                            .font(.system(size: 48))        // Makes it 48 points large
                            .foregroundStyle(.tertiary)     // Makes it very light gray
                        
                        Text("No Notes")                    // Main message when list is empty
                            .font(.title2)                  // Large title size
                            .fontWeight(.medium)            // Medium boldness
                            .foregroundStyle(.secondary)    // Gray color
                        
                        Text("Create your first note by tapping the compose button.")    // Instruction text
                            .font(.subheadline)                                          // Smaller text size
                            .foregroundStyle(.tertiary)                                 // Light gray color
                            .multilineTextAlignment(.center)                            // Centers text if it wraps
                            .padding(.horizontal, 32)                                   // Adds 32 points space on left and right
                    }
                }
            }
        }
        .onChange(of: editingNote) { _, newValue in                      // When editingNote variable changes
            print("editingNote changed to: \(newValue?.title ?? "nil")") // Sends debug message to console showing which note is being edited
        }
    }
    
    private func deleteNote(_ note: Note) {    // Function that deletes a single note
        withAnimation {                        // Makes the deletion animate smoothly
            viewContext.delete(note)           // Removes the note from the database
            saveContext()                      // Saves the changes to permanent storage
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {         // Function that deletes multiple notes (from swipe-to-delete)
        withAnimation {                                    // Makes the deletion animate smoothly
            offsets.map { notes[$0] }.forEach(viewContext.delete)    // Converts row numbers to actual notes and deletes each one
            saveContext()                                  // Saves the changes to permanent storage
        }
    }
    
    private func saveContext() {    // Function that saves changes to the database permanently
        do {                        // Tries to save
            try viewContext.save()  // Attempts to write changes to permanent storage
            print("Context saved successfully")    // Success message to console
        } catch {                   // If saving fails
            print("Error saving context: \(error)")    // Error message to console with details
        }
    }
}

#Preview {    // Creates a preview for developers to see how the screen looks
    NotesListView()    // Shows the notes list view
        .environment(\.managedObjectContext, PreviewContainer.createEmpty().context)    // Uses an empty database for the preview
}
