import SwiftUI

struct ThreePlayersView: View {
    @StateObject var gameController: GameController
    @State private var selectedCard: Card?
    @State private var selectedTrump: Suit?

    init(playerNames: [String]) {
        _gameController = StateObject(wrappedValue: GameController(playerNames: playerNames))
    }

    var body: some View {
        ZStack {
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("ẞELØT - SH!ØT (3-Player)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    if let trump = gameController.game.trump {
                        HStack {
                            Text("Trump: \(trump.rawValue)")
                                .font(.headline)
                                .foregroundColor(.red)
                            if let trumpPlayer = gameController.game.trumpPlayer {
                                Text("(\(trumpPlayer.name))")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.7))

                // Game Area
                Group {
                    switch gameController.game.currentPhase {
                    case .waitingForPlayers, .dealing:
                        WaitingForGameView(gameController: gameController)

                    case .trumpSelection:
                        TrumpSelectionView(gameController: gameController, selectedTrump: $selectedTrump)

                    case .playing:
                        ThreePlayerGamePlayView(
                            gameController: gameController,
                            selectedCard: $selectedCard
                        )

                    case .roundEnd:
                        RoundEndView(gameController: gameController)

                    case .gameEnd:
                        GameEndView(gameController: gameController)
                    }
                }
                .frame(maxHeight: .infinity)

                // Scoreboard
                ScoreboardView(gameController: gameController)
            }
            .navigationTitle("3-Player Game")
            .alert("Error", isPresented: $gameController.showError) {
                Button("OK") { gameController.showError = false }
            } message: {
                Text(gameController.errorMessage)
            }
            .onAppear {
                gameController.startGame()
            }
        }
    }
}

// MARK: - Three Player Game Play View
struct ThreePlayerGamePlayView: View {
    @ObservedObject var gameController: GameController
    @Binding var selectedCard: Card?

    var body: some View {
        VStack(spacing: 16) {
            // Current player info
            if let currentPlayer = gameController.getCurrentPlayer() {
                HStack {
                    Text("Current: \(currentPlayer.name)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    if currentPlayer.combinations.count > 0 {
                        Text("Combos: \(currentPlayer.combinations.count)")
                            .font(.caption)
                            .padding(4)
                            .background(Color.yellow.opacity(0.5))
                            .cornerRadius(4)
                    }
                }
                .padding()
            }

            // Cards on table
            if !gameController.game.currentTrick.playedCards.isEmpty {
                VStack {
                    Text("Cards on table:")
                        .font(.headline)
                    HStack {
                        ForEach(Array(gameController.game.currentTrick.playedCards.values), id: \.id) { card in
                            CardView(card: card, isSelected: false, action: {})
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.3))
                .cornerRadius(8)
            }

            // Player's hand
            if let currentPlayer = gameController.getCurrentPlayer() {
                VStack {
                    Text("\(currentPlayer.name)'s hand:")
                        .font(.headline)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(currentPlayer.hand, id: \.id) { card in
                                CardView(
                                    card: card,
                                    isSelected: selectedCard?.id == card.id,
                                    action: { selectedCard = card }
                                )
                            }
                        }
                    }
                }
                .padding()

                Button("Play Selected Card") {
                    if let selected = selectedCard {
                        gameController.playCard(selected)
                        selectedCard = nil
                    }
                }
                .disabled(selectedCard == nil)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedCard != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ThreePlayersView(playerNames: ["Player 1", "Player 2", "Player 3"])
    }
}