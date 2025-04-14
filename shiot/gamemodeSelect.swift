import SwiftUI

// Vanea si Roma, ne trogati

struct gamemodeSelect: View {
    var body: some View {
        ZStack {
            VStack {
                Text("P1 name:").padding()
                Text("P2 name:").padding()
                Text("P3 name:").padding()
            }.padding()
        }
    }
}

#Preview {
    NavigationStack {
        gamemodeSelect()
    }
}
