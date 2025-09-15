//
//  EmptyNotesView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation    // Brings in basic Swift utilities like Date, String functions, etc.
import CoreData     // Brings in Apple's database system for storing data permanently
import SwiftUI      // Brings in Apple's modern user interface framework

struct EmptyNotesView: View {    // Creates a new screen component that shows when there are no notes to display
    @State private var isAnimating = false    // Creates a variable that tracks whether an animation is currently running, starts as false
    
    var body: some View {    // Defines what this screen looks like visually
        VStack(spacing: 20) {    // Arranges all elements vertically with 20 points of space between each item
            Image(systemName: "note.text")    // Shows Apple's built-in note icon
                .font(.system(size: 60))       // Makes the icon 60 points large
                .foregroundStyle(.secondary)   // Colors it gray (secondary color)
            
            Text("No Notes Yet")               // Displays the main heading text
                .font(.title2)                 // Makes it a large title size
                .fontWeight(.medium)           // Makes it medium boldness
                .foregroundStyle(.secondary)   // Colors it gray
            
            Text("Tap the + button to create your first note")    // Shows instruction text to the user
                .font(.subheadline)                                // Smaller text size
                .foregroundStyle(.tertiary)                       // Even lighter gray color
                .multilineTextAlignment(.center)                  // Centers text if it wraps to multiple lines
                .padding(.horizontal, 40)                         // Adds 40 points of space on left and right sides
            
            // Animated plus icon
            Image(systemName: "plus.circle.fill")    // Shows a filled plus button icon
                .font(.title3)                       // Medium-large size
                .foregroundStyle(.tint)              // Uses the app's accent color
                .opacity(0.7)                        // Makes it 70% transparent
                .scaleEffect(isAnimating ? 1.1 : 1.0)    // Makes it 10% bigger when animating, normal size when not
                .onAppear {                               // When this icon first appears on screen
                    withAnimation(                        // Creates a smooth animation
                        Animation.easeInOut(duration: 1.5)         // Animation lasts 1.5 seconds with smooth in/out
                            .repeatForever(autoreverses: true)     // Repeats forever and goes back and forth
                    ) {
                        isAnimating = true    // Triggers the scale effect to make the icon pulse
                    }
                }
        }
        .padding()    // Adds space around the entire view
    }
}

// MARK: - Previews
#Preview("Empty State") {    // Creates a preview for developers to see how the view looks normally
    EmptyNotesView()         // Shows the empty notes view
}

#Preview("Dark Mode") {                    // Creates a preview for dark mode
    EmptyNotesView()                       // Shows the empty notes view
        .preferredColorScheme(.dark)       // Forces it to use dark mode colors
}

#Preview("In Navigation") {    // Creates a preview showing how it looks inside a navigation view
    NavigationView {           // Wraps the view in a navigation container
        EmptyNotesView()       // Shows the empty notes view
            .navigationTitle("Notes")    // Adds "Notes" as the navigation title
    }
}

// Traditional PreviewProvider for size variations
struct EmptyNotesView_Previews: PreviewProvider {    // Alternative way to create previews (older style)
    static var previews: some View {                  // Defines what the preview shows
        VStack(spacing: 40) {                         // Arranges preview elements vertically with 40 points spacing
            Text("Standard Size")                     // Label for the first preview
                .font(.caption)                       // Small text size
                .foregroundStyle(.secondary)          // Gray color
            
            EmptyNotesView()                          // Shows the view at normal size
                .frame(maxHeight: 200)               // Limits it to maximum 200 points tall
            
            Divider()                                 // Adds a horizontal line separator
            
            Text("Compact View")                      // Label for the second preview
                .font(.caption)                       // Small text size
                .foregroundStyle(.secondary)          // Gray color
            
            EmptyNotesView()                          // Shows the view again
                .scaleEffect(0.8)                    // Makes it 80% of normal size (smaller)
                .frame(maxHeight: 160)               // Limits it to maximum 160 points tall
        }
        .padding()                                    // Adds space around the entire preview
        .previewDisplayName("Size Variations")       // Names this preview "Size Variations" in Xcode
    }
}
