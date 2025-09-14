//
//  ExportImport.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - DTO for portable JSON
public struct NoteDTO: Codable, Hashable, Identifiable {
    public let id: UUID
    public let title: String
    public let content: String
    public let timestamp: Date
    
    public init(title: String, content: String, timestamp: Date) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.timestamp = timestamp
    }
    
    // Custom coding keys to exclude id from JSON
    private enum CodingKeys: String, CodingKey {
        case title, content, timestamp
    }
    
    // Custom decoder that generates new UUID
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    // Custom encoder that excludes id from JSON
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - Core Data to DTO Mapping
public func makeDTOs(from notes: [Note]) -> [NoteDTO] {
    return notes.compactMap { noteEntity in
        guard let title = noteEntity.value(forKey: "title") as? String,
              let timestamp = noteEntity.value(forKey: "timestamp") as? Date else {
            print("Warning: Skipping note with missing required fields")
            return nil
        }
        
        let content = noteEntity.value(forKey: "content") as? String ?? ""
        
        return NoteDTO(
            title: title,
            content: content,
            timestamp: timestamp
        )
    }
}

// MARK: - Core Data Fetch Operations
public func fetchAllNotes(_ ctx: NSManagedObjectContext) throws -> [Note] {
    let request: NSFetchRequest<Note> = NSFetchRequest<Note>(entityName: "Note")
    request.sortDescriptors = [
        NSSortDescriptor(key: "timestamp", ascending: false)
    ]
    return try ctx.fetch(request)
}

// MARK: - FileManager Helpers
public func documentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

public func printDocumentsURL() {
    let url = documentsURL()
    print("Documents URL: \(url.path)")
}

// MARK: - Export Operations
@discardableResult
public func exportNotesToDocuments(_ notes: [Note]) throws -> URL {
    let dtos = makeDTOs(from: notes)
    
    guard !dtos.isEmpty else {
        throw ExportError.noNotesToExport
    }
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    
    let data = try encoder.encode(dtos)
    
    let formatter = ISO8601DateFormatter()
    let timestamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
    let filename = "notes-\(timestamp).json"
    let url = documentsURL().appendingPathComponent(filename)
    
    try data.write(to: url, options: .atomic)
    print("Exported \(dtos.count) notes to: \(url.path)")
    
    return url
}

// MARK: - JSON Decoding
public func decodeNoteDTOs(from data: Data) throws -> [NoteDTO] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([NoteDTO].self, from: data)
}

// MARK: - Import Operations
public func importNotes(from url: URL, into ctx: NSManagedObjectContext, replace: Bool) throws {
    guard url.startAccessingSecurityScopedResource() else {
        throw ImportError.fileAccessDenied
    }
    
    defer {
        url.stopAccessingSecurityScopedResource()
    }
    
    let data = try Data(contentsOf: url)
    let dtos = try decodeNoteDTOs(from: data)
    try importNotes(from: dtos, into: ctx, replace: replace)
}

public func importNotes(from dtos: [NoteDTO], into ctx: NSManagedObjectContext, replace: Bool) throws {
    guard !dtos.isEmpty else {
        throw ImportError.noNotesToImport
    }
    
    // Perform import on background queue for better performance
    try ctx.performAndWait {
        if replace {
            try deleteAllNotes(in: ctx)
        }
        
        // Build a set for deduplication if merging
        var existingKeys = Set<String>()
        
        if !replace {
            let existing = try fetchAllNotes(ctx)
            existingKeys = Set(existing.compactMap { noteEntity in
                guard let noteTitle = noteEntity.value(forKey: "title") as? String,
                      let noteTimestamp = noteEntity.value(forKey: "timestamp") as? Date else { return nil }
                return keyFor(title: noteTitle, timestamp: noteTimestamp)
            })
        }

        var importedCount = 0
        
        for dto in dtos {
            let key = keyFor(title: dto.title, timestamp: dto.timestamp)
            
            if replace || !existingKeys.contains(key) {
                let note = Note(context: ctx)
                // Use setValue to avoid ambiguity
                note.setValue(dto.title, forKey: "title")
                note.setValue(dto.content, forKey: "content")
                note.setValue(dto.timestamp, forKey: "timestamp")
                importedCount += 1
            }
        }
        
        if ctx.hasChanges {
            try ctx.save()
        }
        
        let action = replace ? "replaced" : "merged"
        print("Import complete. \(action) \(importedCount) notes from \(dtos.count) total")
    }
}

// MARK: - Delete Operations
public func deleteAllNotes(in ctx: NSManagedObjectContext) throws {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    let result = try ctx.execute(deleteRequest) as? NSBatchDeleteResult
    
    if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [ctx])
    }
    
    print("All notes deleted successfully")
}

// MARK: - Helper Functions
private func keyFor(title: String, timestamp: Date) -> String {
    let formatter = ISO8601DateFormatter()
    return "\(title)|\(formatter.string(from: timestamp))"
}

// MARK: - Error Types
public enum ExportError: LocalizedError {
    case noNotesToExport
    
    public var errorDescription: String? {
        switch self {
        case .noNotesToExport:
            return "No notes available to export"
        }
    }
}

public enum ImportError: LocalizedError {
    case fileAccessDenied
    case noNotesToImport
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "Unable to access the selected file"
        case .noNotesToImport:
            return "No notes found in the selected file"
        case .invalidData:
            return "The selected file contains invalid data"
        }
    }
}
