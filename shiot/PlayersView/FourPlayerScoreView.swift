import SwiftUI

struct FourPlayerScoreView: View {
    @StateObject var gameSession: GameSession

    init(playerNames: [String]) {
        _gameSession = StateObject(wrappedValue: GameSession(playerNames: playerNames))
    }

    var body: some View {
        ZStack {
            NotebookBackgroundView(hasRuledLines: true, hasMargin: true)

            VStack(spacing: 0) {
                NotebookTitle(text: "ẞELØT", subtitle: "SH!ØT - Score Counter (4P)")
                    .slideInAnimation()

                HStack {
                    Text("Round \(gameSession.currentRound + 1)")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Text("Win at: \(gameSession.winThreshold) bile")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .notebookCard()

                NotebookDivider()

                ScrollView {
                    VStack(spacing: 20) {
                        // Team Display
                        HStack(spacing: 16) {
                            VStack(alignment: .center, spacing: 8) {
                                Text("Team 1")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                ForEach([0, 2], id: \.self) { index in
                                    if index < gameSession.players.count {
                                        Text(gameSession.players[index].name)
                                            .font(.caption)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)

                            VStack(alignment: .center, spacing: 8) {
                                Text("Team 2")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                ForEach([1, 3], id: \.self) { index in
                                    if index < gameSession.players.count {
                                        Text(gameSession.players[index].name)
                                            .font(.caption)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding()

                        // Score Input
                        ForEach(gameSession.players, id: \.id) { player in
                            PlayerScoreInputCard(
                                gameSession: gameSession,
                                player: player,
                                onAddCombo: {}
                            )
                        }

                        VStack(spacing: 12) {
                            Button(action: { gameSession.finishRound() }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Finish Round")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.3))
                                .border(Color.black, width: 2)
                                .foregroundColor(.black)
                            }

                            Button(action: { gameSession.resetGame() }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("New Game")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .border(Color.black, width: 2)
                                .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .notebookCard()
                    }
                    .padding()
                }

                NotebookDivider()
                ScoreSummaryView(gameSession: gameSession)
            }
            .navigationTitle("4-Player Score Counter")
        }
    }
}

#Preview {
    NavigationStack {
        FourPlayerScoreView(playerNames: ["Player 1", "Player 2", "Player 3", "Player 4"])
    }
}
