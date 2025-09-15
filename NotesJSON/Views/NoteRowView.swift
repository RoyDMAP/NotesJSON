//
//  NoteRowView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import SwiftUI      // Brings in Apple's modern user interface framework
import CoreData     // Brings in Apple's database system for storing data permanently

struct NoteRowView: View {    // Creates a reusable component that displays a single note in a list
    let note: Note            // Receives a Note object to display (passed from the parent view)
    
    var body: some View {     // Defines what this row looks like visually
        VStack(alignment: .leading, spacing: 6) {    // Arranges elements vertically, aligned to left, with 6 points spacing
            HStack {          // Arranges title and timestamp horizontally
                Text(note.displayTitle)    // Shows the note's title using a custom property that handles empty titles
                    .font(.headline)       // Makes the text larger and bold like a headline
                    .lineLimit(1)          // Limits title to one line only, adds "..." if too long
                
                Spacer()      // Pushes the timestamp to the right side of the row
                
                if let noteTimestamp = note.timestamp {    // If the note has a timestamp (checks for nil)
                    Text(noteTimestamp, style: .relative)  // Shows relative time like "2 hours ago" or "yesterday"
                        .font(.caption)                     // Makes it small text
                        .foregroundStyle(.tertiary)        // Makes it very light gray color
                }
            }
            
            if note.hasContent {          // If the note has content (using custom property to check)
                Text(note.content!)       // Shows the note's content (! is safe because hasContent checked first)
                    .font(.body)          // Uses standard body text size
                    .foregroundStyle(.secondary)    // Makes it medium gray color
                    .lineLimit(3)         // Limits content to 3 lines maximum, adds "..." if longer
            }
        }
        .padding(.vertical, 4)    // Adds 4 points of space above and below the entire row
    }
}

// MARK: - Previews
#Preview("Standard Note") {    // Creates a preview showing a normal note
    List {                     // Wraps the row in a list to see how it looks in context
        NoteRowView(note: createSampleNote(    // Creates a sample note for testing
            withTitle: "Meeting Notes",        // Sets the title
            content: "Discussed project timeline, budget allocation, and team responsibilities. Need to follow up on resource requirements."    // Sets longer content to test text wrapping
        ))
    }
}

#Preview("Note Variations") {    // Creates a preview showing different types of notes
    List {                       // Wraps multiple rows in a list
        NoteRowView(note: createSampleNote(    // First sample: long title and content
            withTitle: "Long Meeting Notes with Detailed Information That Goes On",    // Very long title to test truncation
            content: "This is a very long note content that should demonstrate how the text wraps and gets limited to three lines maximum. It should show the ellipsis at the end when the content is too long to fit in the available space."    // Long content to test line limiting
        ))
        
        NoteRowView(note: createSampleNote(    // Second sample: normal note with timestamp
            withTitle: "Shopping List",        // Normal length title
            content: "Milk, Bread, Eggs, Butter, Cheese, Apples",    // Medium length content
            hoursAgo: 2                        // Creates timestamp 2 hours ago
        ))
        
        NoteRowView(note: createSampleNote(    // Third sample: note with no content
            withTitle: "Important Reminder",   // Title only
            content: "",                       // Empty content to test how empty content is handled
            daysAgo: 1                        // Creates timestamp 1 day ago
        ))
        
        NoteRowView(note: createSampleNote(    // Fourth sample: older note
            withTitle: "Old Note",             // Title
            content: "This is an older note from several days ago to test the timestamp display.",    // Content explaining the test
            daysAgo: 5                        // Creates timestamp 5 days ago
        ))
        
        NoteRowView(note: createSampleNote(    // Fifth sample: recent note
            withTitle: "Recent Note",          // Title
            content: "Just added this note a few minutes ago."    // Content explaining it's recent
        ))
    }
}

#Preview("Dark Mode") {        // Creates a preview showing how the view looks in dark mode
    List {                     // Wraps rows in a list
        NoteRowView(note: createSampleNote(    // First dark mode sample
            withTitle: "Dark Mode Note",       // Title
            content: "This shows how the note looks in dark mode with different color schemes and styling."    // Content explaining dark mode testing
        ))
        
        NoteRowView(note: createSampleNote(    // Second dark mode sample
            withTitle: "Another Dark Note",    // Title
            content: "Just a title, no content."    // Simple content
        ))
    }
    .preferredColorScheme(.dark)    // Forces the preview to use dark mode colors and styling
}
