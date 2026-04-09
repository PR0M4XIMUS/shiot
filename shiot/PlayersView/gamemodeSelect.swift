import SwiftUI

struct gamemodeSelect: View {
    let numberOfPlayers: Int
    @State private var playerNames: [String] = []
    @State private var showGame = false

    init(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        _playerNames = State(initialValue: Array(repeating: "", count: numberOfPlayers))
    }

    var body: some View {
        ZStack {
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            VStack(spacing: 16) {
                Text("ẞELØT - SH!ØT")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding()

                Text("\(numberOfPlayers)-Player Score Counter")
                    .font(.headline)

                // Player name inputs
                VStack(spacing: 12) {
                    ForEach(0..<numberOfPlayers, id: \.self) { playerNumber in
                        HStack {
                            Text("Player \(playerNumber + 1):")
                                .frame(width: 100, alignment: .leading)
                            TextField("Name", text: $playerNames[playerNumber])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(8)

                Spacer()

                // Start button
                NavigationLink(
                    destination: {
                        let finalPlayerNames = playerNames.enumerated().map { index, name in
                            name.isEmpty ? "Player \(index + 1)" : name
                        }
                        if numberOfPlayers == 2 {
                            TwoPlayerScoreView(playerNames: finalPlayerNames)
                        } else if numberOfPlayers == 3 {
                            ThreePlayerScoreView(playerNames: finalPlayerNames)
                        } else {
                            FourPlayerScoreView(playerNames: finalPlayerNames)
                        }
                    },
                    isActive: $showGame
                ) {
                    Button(action: { showGame = true }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Counter")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        gamemodeSelect(numberOfPlayers: 3)
    }
}
