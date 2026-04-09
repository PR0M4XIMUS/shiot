import SwiftUI

struct TwoPlayerScoreView: View {
    @StateObject var gameSession: GameSession
    @State private var showCombinationPicker = false
    @State private var selectedPlayerForCombos: Int?

    init(playerNames: [String]) {
        _gameSession = StateObject(wrappedValue: GameSession(playerNames: playerNames))
    }

    var body: some View {
        ZStack {
            NotebookBackgroundView(hasRuledLines: true, hasMargin: true)

            VStack(spacing: 0) {
                // Header
                NotebookTitle(text: "ẞELØT", subtitle: "SH!ØT - Score Counter")
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
                        // Score Input for Each Player
                        ForEach(gameSession.players, id: \.id) { player in
                            PlayerScoreInputCard(
                                gameSession: gameSession,
                                player: player,
                                onAddCombo: { selectedPlayerForCombos = player.playerNumber - 1 }
                            )
                        }

                        // Finish Round Button
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

                // Scoreboard
                ScoreSummaryView(gameSession: gameSession)
            }
            .navigationTitle("2-Player Score Counter")
        }
    }
}

// MARK: - Player Score Input Card
struct PlayerScoreInputCard: View {
    @ObservedObject var gameSession: GameSession
    @ObservedObject var player: ScorekeeperPlayer
    let onAddCombo: () -> Void

    @State private var scoreInput: String = ""
    @State private var showCombinationPopover = false

    var body: some View {
        VStack(spacing: 12) {
            Text(player.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trick Points")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("0", text: $scoreInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button(action: {
                    if !scoreInput.isEmpty, let points = Int(scoreInput) {
                        gameSession.addRoundScore(playerIndex: player.playerNumber - 1, points: points)
                        scoreInput = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            // Combinations List
            if !player.roundCombinations.indices.contains(gameSession.currentRound) ||
               player.roundCombinations[gameSession.currentRound].isEmpty {
                Button(action: { showCombinationPopover = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Combination")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Combinations")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ForEach(player.roundCombinations[gameSession.currentRound], id: \.id) { combo in
                        HStack {
                            Text(combo.name)
                                .font(.caption)
                            Spacer()
                            Text("\(combo.points) pts")
                                .font(.caption)
                                .fontWeight(.bold)
                            Button(action: {
                                gameSession.removeCombination(
                                    playerIndex: player.playerNumber - 1,
                                    combinationId: combo.id
                                )
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(6)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(4)
                    }

                    Button(action: { showCombinationPopover = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }

            // Round Total
            let roundTotal = (player.roundScores[safe: gameSession.currentRound] ?? 0) +
                             (player.roundCombinations[safe: gameSession.currentRound]?.reduce(0) { $0 + $1.points } ?? 0)
            let bile = roundTotal / 10

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Round")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(roundTotal) pts")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total Bile")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(player.totalBile) bile")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
        }
        .notebookCard()
        .sheet(isPresented: $showCombinationPopover) {
            CombinationPickerView(
                isPresented: $showCombinationPopover,
                onSelect: { name, points in
                    gameSession.addCombination(playerIndex: player.playerNumber - 1, name: name, points: points)
                }
            )
        }
        .onChange(of: gameSession.currentRound) { _ in
            scoreInput = ""
        }
        .onAppear {
            // Ensure round combinations array is initialized
            while player.roundCombinations.count <= gameSession.currentRound {
                player.roundCombinations.append([])
            }
        }
    }
}

// MARK: - Combination Picker
struct CombinationPickerView: View {
    @Binding var isPresented: Bool
    let onSelect: (String, Int) -> Void

    let combinations: [(name: String, points: Int)] = [
        ("Bela (Q+K Trump)", 20),
        ("Tărcă (2-card sequence)", 20),
        ("Sută (3-card sequence)", 50),
        ("Jumătate (4-card sequence)", 100),
        ("Două sute (5-card sequence)", 200),
        ("Patru șapte", 0),
        ("Patru opt", 100),
        ("Patru nouă", 150),
        ("Patru valet", 200),
        ("Patru zeci/damă/crai/as", 100),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(combinations, id: \.name) { combo in
                    Button(action: {
                        onSelect(combo.name, combo.points)
                        isPresented = false
                    }) {
                        HStack {
                            Text(combo.name)
                            Spacer()
                            Text("\(combo.points)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .foregroundColor(.black)
                }
            }
            .navigationTitle("Select Combination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - Score Summary
struct ScoreSummaryView: View {
    @ObservedObject var gameSession: GameSession

    var body: some View {
        VStack(spacing: 10) {
            Text("Leaderboard")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(gameSession.players.sorted(by: { $0.totalBile > $1.totalBile }), id: \.id) { player in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("Rounds:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(player.roundScores.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }

                        HStack(spacing: 8) {
                            Text("Bile:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(player.totalBile)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.5))
                .border(Color.black.opacity(0.2), width: 1)
            }
        }
        .padding(10)
        .background(Color(red: 0.98, green: 0.97, blue: 0.94))
        .border(Color.black.opacity(0.2), width: 1)
    }
}

#Preview {
    NavigationStack {
        TwoPlayerScoreView(playerNames: ["Player 1", "Player 2"])
    }
}
