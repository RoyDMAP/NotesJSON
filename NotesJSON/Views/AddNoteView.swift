//
//  AddNoteView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI //Brings in Apple's modern user interface framework
import CoreData //Brings in Apple's database system for storing data
import Foundation //Brings in basic Swift utilities like Date, String, Function etc.

struct AddNoteView: View { //Creates a new screen called "AddNoteView" that follows SwiftUI's View rules
    @Environment(\.managedObjectContext) private var viewContext //Gets access to the app's database connection from the surrounding environments
    @Environment(\.dismiss) private var dismiss // Gets function from the environment that can close this screen
    
    @State private var title: String = "" //Sotres the note's title text, starts empty
    @State private var content: String = "" //Stores the note's main text, starts empty
    @FocusState private var isTitleFocused: Bool // Tracks wheter the title text fielf is currently selected/active
    
    var body: some View { //Builds the visual layout
        NavigationView { //Creates a screen with a navigation bar at the top
            VStack(spacing: 16) { // Arranges things vertically (top to Bottom) with 16 points of space between items
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title") // Shows the word "Title" as a label
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter note title", text: $title) //Creates a text input box where users can type// $title: connects the text field to the title variable (two-way binding)
                        .textFieldStyle(.roundedBorder) // Stypes for the texfield
                        .focused($isTitleFocused) // Makes the text field active when isTitleFocused is true
                }
                
                // Content Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isTitleFocused = true
        }
    }
    
    // FIXED: Added proper Core Data saving
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines) //Removes extra spaces and line breaks from the begining and end of the title
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines) // Does the same for the content
        
        // Don't save empty notes
        guard !trimmedTitle.isEmpty else { return } //checks if the title is empty after trimming, if empty, stops the function and doesn't save anything
        
        // Create the note
        let note = Note(context: viewContext) //Creates a new note object in the database
        note.title = trimmedTitle // Sets the title to the cleaned-up title text
        note.content = trimmedContent.isEmpty ? nil : trimmedContent //sets content to the cleaned-up content, or nil if it's empty
        note.timestamp = Date() //Sets timestamp to the current date and time
        
        // CRITICAL: Save to persistent store
        do {
            try viewContext.save() // Attempts to save the note to the permanent database
            print("Note saved successfully: \(trimmedTitle)") //If successful, prints a success message and closes the screen
            dismiss()
        } catch {
            print("Error saving note: \(error)") //If it fails: prints an error message
            // Handle the error appropriately in your app
        }
    }
}
