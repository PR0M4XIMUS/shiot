import SwiftUI

struct gamemodeSelect: View {
    let numberOfPlayers: Int
    @State private var playerNames: [String] = []

    init(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        _playerNames = State(initialValue: Array(repeating: "", count: numberOfPlayers))
    }

    var body: some View {
        ZStack {
            VStack {
                ForEach(0..<numberOfPlayers, id: \.self) { playerNumber in
                    HStack {
                        Text("P\(playerNumber + 1) name:").padding(.trailing, 5)
                        TextField("Enter name", text: $playerNames[playerNumber])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 5)
                    }
                    .padding(.bottom, 10) 
                }
            }
            .padding()
            .onAppear {
                playerNames = Array(repeating: "", count: numberOfPlayers)
            }
        }
    }
}

#Preview {
    NavigationStack {
        gamemodeSelect(numberOfPlayers: 3)
    }
}
