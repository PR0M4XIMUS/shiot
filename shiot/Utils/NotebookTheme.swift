import SwiftUI

// MARK: - Notebook Background
struct NotebookBackgroundView: View {
    let hasRuledLines: Bool
    let hasMargin: Bool

    var body: some View {
        ZStack {
            // Paper background
            Color(red: 0.98, green: 0.97, blue: 0.94)
                .edgesIgnoringSafeArea(.all)

            if hasRuledLines {
                VStack(spacing: 24) {
                    ForEach(0..<100, id: \.self) { _ in
                        VStack(spacing: 0) {
                            Spacer()
                            Canvas { context, size in
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: size.height))
                                path.addLine(to: CGPoint(x: size.width, y: size.height))
                                context.stroke(path, with: .color(.blue.opacity(0.2)), lineWidth: 0.5)
                            }
                            .frame(height: 1)
                        }
                    }
                }
            }

            if hasMargin {
                HStack(spacing: 0) {
                    // Red margin line
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 1)
                        .padding(.leading, 25)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Notebook Card
struct NotebookCardView<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let borderColor: Color
    let shadowColor: Color

    init(backgroundColor: Color = Color(red: 0.99, green: 0.98, blue: 0.96),
         borderColor: Color = Color.black.opacity(0.1),
         shadowColor: Color = Color.black.opacity(0.1),
         @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(backgroundColor)
            .border(borderColor, width: 1)
            .shadow(color: shadowColor, radius: 2, x: 1, y: 1)
    }
}

// MARK: - Handwritten Style Button
struct HandwrittenButton: View {
    let label: String
    let action: () -> Void
    let isEnabled: Bool
    let rotation: Double

    init(_ label: String, rotation: Double = Double.random(in: -1.5...1.5), isEnabled: Bool = true, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.isEnabled = isEnabled
        self.rotation = rotation
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(isEnabled ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                .border(Color.black.opacity(0.3), width: 1)
                .cornerRadius(4)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 0, z: 1))
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Card Display with Notebook Style
struct NotebookCardDisplay: View {
    let card: Card
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(card.rank.displayName)
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .lineLimit(1)

                Text(card.suit.rawValue)
                    .font(.system(size: 20, weight: .bold, design: .default))
            }
            .frame(width: 55, height: 75)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .border(Color.black, width: 2)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.yellow, lineWidth: 3)
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
        }
        .foregroundColor(.black)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Notebook Title
struct NotebookTitle: View {
    let text: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.green)
                .tracking(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Notebook Divider
struct NotebookDivider: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height / 2))

            for x in stride(from: 0, to: size.width, by: 3) {
                path.addLine(to: CGPoint(x: x, y: size.height / 2))
                path.addLine(to: CGPoint(x: x + 2, y: size.height / 2))
            }

            context.stroke(path, with: .color(.black.opacity(0.2)), lineWidth: 0.5)
        }
        .frame(height: 1)
        .padding(.vertical, 12)
    }
}

// MARK: - Animations
struct CardFlipAnimation: ViewModifier {
    @State private var isFlipped = false

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
            .onTapGesture {
                isFlipped.toggle()
            }
    }
}

struct SlideInAnimation: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : -50)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4)) {
                    isVisible = true
                }
            }
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func notebookCard(backgroundColor: Color = Color(red: 0.99, green: 0.98, blue: 0.96),
                      borderColor: Color = Color.black.opacity(0.1)) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .border(borderColor, width: 1)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 1, y: 1)
    }

    func cardFlipAnimation() -> some View {
        modifier(CardFlipAnimation())
    }

    func slideInAnimation() -> some View {
        modifier(SlideInAnimation())
    }

    func pulseAnimation() -> some View {
        modifier(PulseAnimation())
    }
}

// MARK: - Color Palette
struct NotebookColors {
    static let paperBackground = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let ruledLineColor = Color.blue.opacity(0.2)
    static let marginColor = Color.red.opacity(0.3)
    static let accentGreen = Color.green
    static let accentRed = Color.red
    static let textDark = Color.black
    static let textLight = Color.gray
    static let cardBorder = Color.black.opacity(0.3)
    static let shadowColor = Color.black.opacity(0.1)
}
