import SwiftUI

extension View {
    /// Hide keyboard when needed
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// Custom button style for Belot game
struct BelotButtonStyle: ButtonStyle {
    var backgroundColor: Color = .green

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// Card display helper
struct CardDisplayView: View {
    let card: Card
    let isPlayable: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(card.rank.displayName)
                .font(.headline)
                .fontWeight(.bold)
            Text(card.suit.rawValue)
                .font(.title3)
        }
        .frame(width: 50, height: 70)
        .background(Color.white)
        .border(isPlayable ? Color.green : Color.gray, width: 1)
        .cornerRadius(4)
        .opacity(isPlayable ? 1.0 : 0.6)
    }
}
