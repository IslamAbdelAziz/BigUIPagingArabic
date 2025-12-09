//  VerticalCardDeckExample.swift
//  BigUIPagingArabic
//
//  Created by iSlam AbdelAziz on 07/12/2025.
//

import SwiftUI

/// An example of how to create a deck of cards in a vertical stack.
@available(macOS, unavailable)
struct VerticalCardDeckExample: View {
    @Environment(\.layoutDirection) var layoutDirection

    @State private var selection: Int = 1
    private let totalPages = 10
    
    var body: some View {
        VStack {
            PageeView(selection: $selection, direction: layoutDirection, addRotation: false) {
                ForEach(1...totalPages, id: \.self) { value in
                    ExamplePage(value: value)
                        // Resize to be more card-like.
                        .aspectRatio(0.7, contentMode: .fit)
                }
            }
            // Set the card style
            .pageViewStyle(.verticalCardDeck)
            // Control how much of the card edges are visible
            .scaleEffect(0.9)
            // Card styling options
            .pageViewCardCornerRadius(45.0)
            .pageViewCardShadow(.visible)
            // A tap gesture works great here
            .onTapGesture {
                print("Tapped card \(selection)")
            }
            
            PageIndicator(
                selection: indicatorSelection,
                total: totalPages
            )
            .pageIndicatorColor(.secondary.opacity(0.3))
            .pageIndicatorCurrentColor(selection.color)
        }
    }
    
    // Here's where you'd map your selection to a page index.
    // In this example it's just the selection minus one.
    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

// MARK: - Preview

@available(macOS, unavailable)
struct VerticalCardDeckExample_Previews: PreviewProvider {
    
    static var previews: some View {
        VerticalCardDeckExample()
            .environment(\.layoutDirection, .rightToLeft)
    }
}
