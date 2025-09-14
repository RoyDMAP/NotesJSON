//
//  NoteListView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI
import CoreData

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var showingAddNote = false
    @State private var selectedNote: Note?
    @State private var showingEditNote = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes) { note in
                    NoteRowView(note: note)
                        .onTapGesture {
                            selectedNote = note
                            showingEditNote = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                deleteNote(note)
                            }
                            
                            Button("Edit") {
                                selectedNote = note
                                showingEditNote = true
                            }
                            .tint(.blue)
                        }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
            .sheet(isPresented: $showingEditNote) {
                if let selectedNote = selectedNote {
                    EditNoteView(note: selectedNote)
                }
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately in your app
                print("Error deleting notes: \(error)")
            }
        }
    }
    
    private func deleteNote(_ note: Note) {
        withAnimation {
            viewContext.delete(note)
            
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately in your app
                print("Error deleting note: \(error)")
            }
        }
    }
}

// MARK: - Previews
#Preview("Notes List") {
    // Create some sample data for the preview
    let context = PreviewContainer.shared.context
    
    // Add some sample notes
    let _ = createSampleNote(withTitle: "Meeting Notes", content: "Important meeting about project timeline")
    let _ = createSampleNote(withTitle: "Shopping List", content: "Milk, Bread, Eggs", hoursAgo: 2)
    let _ = createSampleNote(withTitle: "Ideas", content: "App improvement ideas for next sprint", daysAgo: 1)
    
    return NotesListView()
        .environment(\.managedObjectContext, context)
}

#Preview("Empty Notes List") {
    NotesListView()
        .environment(\.managedObjectContext, PreviewContainer.shared.context)
}

#Preview("Dark Mode") {
    let context = PreviewContainer.shared.context
    let _ = createSampleNote(withTitle: "Dark Mode Note", content: "Testing dark mode appearance")
    
    return NotesListView()
        .environment(\.managedObjectContext, context)
        .preferredColorScheme(.dark)
}
