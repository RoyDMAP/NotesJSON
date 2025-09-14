//
//  EditNoteView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI
import CoreData

struct EditNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let note: Note
    
    @State private var title: String = ""
    @State private var content: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter note title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTitleFocused)
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
            .navigationTitle("Edit Note")
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
            loadNoteData()
        }
    }
    
    private func loadNoteData() {
        title = note.title ?? ""
        content = note.content ?? ""
    }
    
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't save empty notes
        guard !trimmedTitle.isEmpty else { return }
        
        note.title = trimmedTitle
        note.content = trimmedContent.isEmpty ? nil : trimmedContent
        note.timestamp = Date() // Update timestamp when edited
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            // Handle the error appropriately in your app
            print("Error saving note: \(error)")
        }
    }
}

// MARK: - Previews
#Preview("Edit Note View") {
    let sampleNote = createSampleNote(
        withTitle: "Sample Note",
        content: "This is some sample content for editing."
    )
    
    return EditNoteView(note: sampleNote)
        .environment(\.managedObjectContext, PreviewContainer.shared.context)
}
