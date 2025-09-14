//
//  NoteRowView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import SwiftUI
import CoreData

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if let noteTimestamp = note.timestamp {
                    Text(noteTimestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            if note.hasContent {
                Text(note.content!)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews
#Preview("Standard Note") {
    List {
        NoteRowView(note: createSampleNote(
            withTitle: "Meeting Notes",
            content: "Discussed project timeline, budget allocation, and team responsibilities. Need to follow up on resource requirements."
        ))
    }
}

#Preview("Note Variations") {
    List {
        NoteRowView(note: createSampleNote(
            withTitle: "Long Meeting Notes with Detailed Information That Goes On",
            content: "This is a very long note content that should demonstrate how the text wraps and gets limited to three lines maximum. It should show the ellipsis at the end when the content is too long to fit in the available space."
        ))
        
        NoteRowView(note: createSampleNote(
            withTitle: "Shopping List",
            content: "Milk, Bread, Eggs, Butter, Cheese, Apples",
            hoursAgo: 2
        ))
        
        NoteRowView(note: createSampleNote(
            withTitle: "Important Reminder",
            content: "",
            daysAgo: 1
        ))
        
        NoteRowView(note: createSampleNote(
            withTitle: "Old Note",
            content: "This is an older note from several days ago to test the timestamp display.",
            daysAgo: 5
        ))
        
        NoteRowView(note: createSampleNote(
            withTitle: "Recent Note",
            content: "Just added this note a few minutes ago."
        ))
    }
}

#Preview("Dark Mode") {
    List {
        NoteRowView(note: createSampleNote(
            withTitle: "Dark Mode Note",
            content: "This shows how the note looks in dark mode with different color schemes and styling."
        ))
        
        NoteRowView(note: createSampleNote(
            withTitle: "Another Dark Note",
            content: "Just a title, no content."
        ))
    }
    .preferredColorScheme(.dark)
}

#Preview("Single Note Focus") {
    VStack(spacing: 0) {
        NoteRowView(note: createSampleNote(
            withTitle: "Focus Test Note",
            content: "This preview shows a single note without the list container to see the exact spacing and layout."
        ))
        .padding(.horizontal, 16)
        
        Divider()
        
        NoteRowView(note: createSampleNote(
            withTitle: "No Content Note",
            content: ""
        ))
        .padding(.horizontal, 16)
    }
    .background(Color(.systemGroupedBackground))
}
