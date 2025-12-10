//  VerticalCardDeckPageViewStyle.swift
//  BigUIPagingArabic
//
//  Created by iSlam AbdelAziz on 07/12/2025.
//

import SwiftUI

/// A style that arranges pages as a whimsical deck of cards in a vertical stack.
///
/// This style mimics the behaviour of the photo stack in iMessage and Big News, but vertically.
///
@available(macOS, unavailable)
@available(iOS 16.0, *)
public struct VerticalCardDeckPageViewStyle: PageViewStyle {
    
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        VerticalCardDeckPageView(configuration)
    }
}

struct VerticalCardDeckPageView: View {
    
    typealias Value = PageViewStyleConfiguration.Value
    typealias Configuration = PageViewStyleConfiguration
    
    struct Page: Identifiable {
        let index: Int
        let value: Value
        
        var id: Value {
            return value
        }
    }
    
    let configuration: Configuration
    
    @State private var dragProgress = 0.0
    @State private var selectedIndex = 0
    @State private var pages = [Page]()
    @State private var containerSize = CGSize.zero
    
    @Environment(\.cardCornerRadius) private var cornerRadius
    @Environment(\.cardShadowDisabled) private var shadowDisabled

    init(_ configuration: Configuration) {
        self.configuration = configuration
    }
    
    var body: some View {
        ZStack {
            ForEach(pages) { page in
                configuration.content(page.value)
                    .cardStyle(cornerRadius: cornerRadius)
                    .zIndex(zIndex(for: page.index))
                    .offset(y: yOffset(for: page.index))
                    .scaleEffect(scale(for: page.index))
                    .rotationEffect(.degrees(configuration.addRotation ? rotation(for: page.index) : 0))
                    .shadow(color: shadow(for: page.index), radius: 30, y: 20)
            }
        }
        .measure($containerSize)
        .scaleEffect(0.8)
        .highPriorityGesture(dragGesture)
        .task {
            makePages(from: configuration.selection.wrappedValue)
        }
        .onChange(of: selectedIndex) { newValue in
            configuration.selection.wrappedValue = pages[newValue].value
        }
        .onChange(of: configuration.selection.wrappedValue) { newValue in
            // Find if newValue is in current pages
            if let newIndex = pages.firstIndex(where: { $0.value == newValue }) {
                let diff = newIndex - selectedIndex
                if diff == 1 {
                    // Next
                    withAnimation(.smooth(duration: 0.25)) {
                        self.dragProgress = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.makePages(from: newValue)
                        self.dragProgress = 0.0
                    }
                    return
                } else if diff == -1 {
                    // Prev
                    withAnimation(.smooth(duration: 0.25)) {
                        self.dragProgress = -1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.makePages(from: newValue)
                        self.dragProgress = 0.0
                    }
                    return
                }
            }
            
            makePages(from: newValue)
            self.dragProgress = 0.0
        }
    }
    
    func makePages(from value: Value) {
        let (values, index) = configuration.values(surrounding: value)
        self.pages = values.enumerated().map {
            Page(index: $0.offset, value: $0.element)
        }
        self.selectedIndex = index
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                // Vertical drag
                self.dragProgress = -(value.translation.height / containerSize.height)
            }
            .onEnded { value in
                snapToNearestIndex()
            }
    }
    
    func snapToNearestIndex() {
        let threshold = 0.3
        if abs(dragProgress) < threshold {
            withAnimation(.bouncy) {
                self.dragProgress = 0.0
            }
        } else {
            let direction = dragProgress < 0 ? -1 : 1 // Drag up (negative) -> next item (increment index), Drag down (positive) -> prev item
            withAnimation(.smooth(duration: 0.25)) {
                go(to: selectedIndex + direction)
                self.dragProgress = 0.0
            }
        }
    }
    
    func go(to index: Int) {
        let maxIndex = pages.count - 1
        if index > maxIndex {
            self.selectedIndex = maxIndex
        } else if index < 0 {
            self.selectedIndex = 0
        } else {
            self.selectedIndex = index
        }
        self.dragProgress = 0
    }
    
    func currentPosition(for index: Int) -> Double {
        progressIndex - Double(index)
    }
    
    // MARK: - Geometry
    
    var progressIndex: Double {
        dragProgress + Double(selectedIndex)
    }
    
    func zIndex(for index: Int) -> Double {
        let position = currentPosition(for: index)
        return -abs(position)
    }
    
    func yOffset(for index: Int) -> Double {
        let padding = containerSize.height / 10
        let y = (Double(index) - progressIndex) * padding
        let maxIndex = pages.count - 1
        
        if index == selectedIndex && progressIndex < Double(maxIndex) && progressIndex > 0 {
            return y * swingOutMultiplier
        }
        return y
    }
    
    var swingOutMultiplier: Double {
        return abs(sin(Double.pi * progressIndex) * 20)
    }
    
    func scale(for index: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: index)))
    }
    
    func rotation(for index: Int) -> Double {
        return -currentPosition(for: index) * 2
    }
    
    func shadow(for index: Int) -> Color {
        guard shadowDisabled == false else {
            return .clear
        }
        let index = Double(index)
        let progress = 1.0 - abs(progressIndex - index)
        let opacity = 0.3 * progress
        return .black.opacity(opacity)
    }
}

@available(macOS, unavailable)
@available(iOS 16.0, *)
extension PageViewStyle where Self == VerticalCardDeckPageViewStyle {
    
    /// A style that presents pages as a whimsical deck of cards in a vertical stack.
    public static var verticalCardDeck: VerticalCardDeckPageViewStyle {
        VerticalCardDeckPageViewStyle()
    }
}
