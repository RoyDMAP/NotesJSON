//
//  EmptyNotesView.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import Foundation
import CoreData
import SwiftUI

struct EmptyNotesView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text("Tap the + button to create your first note")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Animated plus icon
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(.tint)
                .opacity(0.7)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        isAnimating = true
                    }
                }
        }
        .padding()
    }
}

// MARK: - Previews
#Preview("Empty State") {
    EmptyNotesView()
}

#Preview("Dark Mode") {
    EmptyNotesView()
        .preferredColorScheme(.dark)
}

#Preview("In Navigation") {
    NavigationView {
        EmptyNotesView()
            .navigationTitle("Notes")
    }
}

// Traditional PreviewProvider for size variations
struct EmptyNotesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            Text("Standard Size")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            EmptyNotesView()
                .frame(maxHeight: 200)
            
            Divider()
            
            Text("Compact View")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            EmptyNotesView()
                .scaleEffect(0.8)
                .frame(maxHeight: 160)
        }
        .padding()
        .previewDisplayName("Size Variations")
    }
}
