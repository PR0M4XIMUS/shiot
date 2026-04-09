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
            NotebookBackgroundView(hasRuledLines: true, hasMargin: true)

            VStack(spacing: 0) {
                // Header
                NotebookTitle(text: "ẞELØT", subtitle: "SH!ØT - 3 Players")
                    .slideInAnimation()

                if let trump = gameController.game.trump {
                    HStack(spacing: 16) {
                        Text("Trump:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(trump.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.red)
                        if let trumpPlayer = gameController.game.trumpPlayer {
                            Text("(\(trumpPlayer.name))")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .notebookCard()
                }

                NotebookDivider()

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

                NotebookDivider()

                // Scoreboard
                ScoreboardView(gameController: gameController)
            }
            .padding()
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Turn")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(currentPlayer.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    if currentPlayer.combinations.count > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Combinations")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(currentPlayer.combinations.count)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .notebookCard()
            }

            // Cards on table
            if !gameController.game.currentTrick.playedCards.isEmpty {
                VStack(spacing: 12) {
                    Text("Cards on Table")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    HStack(spacing: 12) {
                        ForEach(gameController.game.currentTrick.playedCards, id: \.0) { playerIndex, card in
                            NotebookCardDisplay(card: card, isSelected: false, action: {})
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .notebookCard()
                .pulseAnimation()
            }

            // Player's hand
            if let currentPlayer = gameController.getCurrentPlayer() {
                VStack(spacing: 12) {
                    Text("\(currentPlayer.name) - \(currentPlayer.hand.count) cards")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(currentPlayer.hand, id: \.id) { card in
                                NotebookCardDisplay(
                                    card: card,
                                    isSelected: selectedCard?.id == card.id,
                                    action: { selectedCard = card }
                                )
                                .slideInAnimation()
                            }
                        }
                    }
                }
                .notebookCard()

                HandwrittenButton("Play Card") {
                    if let selected = selectedCard {
                        gameController.playCard(selected)
                        selectedCard = nil
                    }
                }
                .disabled(selectedCard == nil)
                .opacity(selectedCard != nil ? 1.0 : 0.5)
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