//
//  EditNoteView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI        // Brings in Apple's modern user interface framework
import CoreData       // Brings in Apple's database system for storing data permanently
import Foundation     // Brings in basic Swift utilities like Date, String functions, etc.

struct EditNoteView: View {    // Creates a new screen called "EditNoteView" that follows SwiftUI's View rules
    @Environment(\.managedObjectContext) private var viewContext    // Gets access to the app's database connection from the surrounding environment
    @Environment(\.dismiss) private var dismiss                     // Gets a function from the environment that can close this screen
    
    let note: Note    // Receives the specific note that we want to edit (passed from the previous screen)
    
    @State private var title: String = ""            // Stores the note's title text as the user edits it, starts empty
    @State private var content: String = ""          // Stores the note's content text as the user edits it, starts empty
    @State private var showingError = false          // Controls whether an error popup is visible, starts hidden
    @State private var errorMessage = ""             // Stores the text to show in the error popup, starts empty
    @FocusState private var isTitleFocused: Bool     // Tracks whether the title text field is currently selected/active
    
    var body: some View {    // Starts building the visual layout
        NavigationView {     // Creates a screen with a navigation bar at the top
            VStack(spacing: 16) {    // Arranges things vertically (top to bottom) with 16 points of space between items
                // Title Input
                VStack(alignment: .leading, spacing: 8) {    // Creates another vertical stack for the title section, aligned to left
                    Text("Title")                            // Shows the word "Title" as a label
                        .font(.headline)                     // Makes the text larger and bold like a headline
                        .foregroundStyle(.secondary)        // Makes the text color a dimmed gray
                    
                    TextField("Enter note title", text: $title)    // Creates a text input box where users can type
                        .textFieldStyle(.roundedBorder)            // Gives the text field a rounded border style
                        .focused($isTitleFocused)                  // Makes the text field active when isTitleFocused is true
                }
                
                // Content Input
                VStack(alignment: .leading, spacing: 8) {    // Creates another vertical stack for the content section
                    Text("Content")                          // Shows the word "Content" as a label
                        .font(.headline)                     // Makes the text larger and bold
                        .foregroundStyle(.secondary)        // Makes the text color dimmed gray
                    
                    TextEditor(text: $content)              // Creates a multi-line text area for longer text
                        .frame(minHeight: 200)              // Makes it at least 200 points tall
                        .padding(8)                         // Adds 8 points of space inside the text area
                        .background(Color(.systemGray6))    // Gives it a light gray background color
                        .cornerRadius(8)                    // Rounds the corners with 8 point radius
                        .overlay(                           // Adds something on top of the text editor
                            RoundedRectangle(cornerRadius: 8)       // Creates a rounded rectangle shape
                                .stroke(Color(.systemGray4), lineWidth: 1)    // Makes it a gray border line 1 point thick
                        )
                }
                
                Spacer()    // Pushes everything above to the top by taking up remaining space
            }
            .padding()                                      // Adds space around the entire content
            .navigationTitle("Edit Note")                   // Sets the screen title to "Edit Note"
            .navigationBarTitleDisplayMode(.inline)         // Makes the title appear in the navigation bar (not large)
            .toolbar {                                      // Adds buttons to the navigation bar
                ToolbarItem(placement: .navigationBarLeading) {    // Places item on the left side of navigation bar
                    Button("Cancel") {                              // Creates a "Cancel" button
                        dismiss()                                   // When tapped, closes the screen
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {   // Places item on the right side of navigation bar
                    Button("Save") {                                // Creates a "Save" button
                        saveNote()                                  // When tapped, calls the saveNote function
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)    // Grays out button if title is empty after removing spaces
                }
            }
            .alert("Error", isPresented: $showingError) {   // Shows a popup when showingError becomes true
                Button("OK") { }                            // Popup has an "OK" button that dismisses it
            } message: {                                    // The content of the error popup
                Text(errorMessage)                          // Shows whatever text is stored in errorMessage
            }
        }
        .onAppear {         // When the screen first appears
            loadNoteData()  // Call the loadNoteData function
        }
    }
    
    // FIXED: Better data loading with debug info
    private func loadNoteData() {                           // Function that loads the existing note's data into the editing fields
        print("Loading note data:")                         // Sends debug message to Xcode's console
        print("  Title: \(note.title ?? "nil")")          // Shows the note's current title (or "nil" if empty)
        print("  Content: \(note.content ?? "nil")")      // Shows the note's current content (or "nil" if empty)
        
        title = note.title ?? ""      // Copies the note's title to the editing variable (use empty string if nil)
        content = note.content ?? ""  // Copies the note's content to the editing variable (use empty string if nil)
        
        print("Loaded into state:")                // Debug message
        print("  Title state: \(title)")          // Shows what got loaded into the title variable
        print("  Content state: \(content)")      // Shows what got loaded into the content variable
    }
    
    // FIXED: Added proper Core Data saving with persistence
    private func saveNote() {                              // Function that saves the edited note
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)      // Removes extra spaces and line breaks from title
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)  // Removes extra spaces and line breaks from content
        
        // Don't save empty notes
        guard !trimmedTitle.isEmpty else {         // Checks if title is empty after trimming
            errorMessage = "Title cannot be empty" // Sets the error message text
            showingError = true                    // Shows the error popup
            return                                 // Stops the function here, doesn't save
        }
        
        // Update the note
        note.title = trimmedTitle                                              // Updates the original note object with new title
        note.content = trimmedContent.isEmpty ? nil : trimmedContent          // Sets content to new text, or nil if empty
        note.timestamp = Date()                                               // Updates timestamp to current date/time to mark when edited
        
        // CRITICAL: Save to persistent store
        do {                                       // Tries to execute the save operation
            try viewContext.save()                 // Attempts to save changes to the permanent database
            print("Note updated successfully: \(trimmedTitle)")    // Success message to console
            dismiss()                              // Closes the edit screen
        } catch {                                  // If saving fails
            errorMessage = "Failed to save note: \(error.localizedDescription)"    // Creates user-friendly error message
            showingError = true                    // Shows the error popup
            print("Error saving note: \(error)")  // Sends detailed error to console for debugging
        }
    }
}
