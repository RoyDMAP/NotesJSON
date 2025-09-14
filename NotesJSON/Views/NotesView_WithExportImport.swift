//
//  NotesView_WithExportImport.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import SwiftUI
import CoreData

struct NotesView_WithExportImport: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
        animation: .default
    ) private var notes: FetchedResults<Note>
    
    @State private var showingAddNote = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingImportOptions = false
    @State private var exportDocument = JSONFile(data: Data())
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var replaceOnImport = false
    
    var body: some View {
        NavigationView {
            Group {
                if notes.isEmpty {
                    EmptyNotesView()
                } else {
                    List {
                        ForEach(notes) { note in
                            NoteRowView(note: note)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("Export Notes", systemImage: "square.and.arrow.up") {
                            exportNotes()
                        }
                        .disabled(notes.isEmpty)
                        
                        Button("Import Notes", systemImage: "square.and.arrow.down") {
                            showingImportOptions = true
                        }
                        
                        Divider()
                        
                        Button("Add Note", systemImage: "plus") {
                            showingAddNote = true
                        }
                    }
                    
                    Button("Add", systemImage: "plus") {
                        showingAddNote = true
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
            .fileExporter(
                isPresented: $showingExportSheet,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "notes-export"
            ) { result in
                handleExportResult(result)
            }
            .fileImporter(
                isPresented: $showingImportSheet,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .alert("Import Options", isPresented: $showingImportOptions) {
                Button("Replace All Notes") {
                    replaceOnImport = true
                    showingImportSheet = true
                }
                
                Button("Merge with Existing") {
                    replaceOnImport = false
                    showingImportSheet = true
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Do you want to replace all existing notes or merge with existing notes?")
            }
            .alert("Message", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Export Functions
    private func exportNotes() {
        do {
            let allNotes = try fetchAllNotes(viewContext)
            guard !allNotes.isEmpty else {
                alertMessage = "No notes to export."
                showingAlert = true
                return
            }
            
            let dtos = makeDTOs(from: allNotes)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(dtos)
            exportDocument = JSONFile(data: jsonData)
            showingExportSheet = true
        } catch {
            alertMessage = "Export failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            alertMessage = "Notes exported successfully to: \(url.lastPathComponent)"
            showingAlert = true
        case .failure(let error):
            alertMessage = "Export failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // MARK: - Import Functions
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                alertMessage = "No file selected for import."
                showingAlert = true
                return
            }
            performNotesImport(from: url)
        case .failure(let error):
            alertMessage = "Import failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func performNotesImport(from url: URL) {
        do {
            try importNotes(from: url, into: viewContext, replace: replaceOnImport)
            let action = replaceOnImport ? "replaced" : "merged"
            alertMessage = "Notes \(action) successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Import failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // MARK: - Core Data Functions
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                alertMessage = "Delete failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

// MARK: - Previews
#Preview("Notes with Data") {
    NotesView_WithExportImport()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Empty Notes") {
    NotesView_WithExportImport()
        .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
}

#Preview("Dark Mode") {
    NotesView_WithExportImport()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
