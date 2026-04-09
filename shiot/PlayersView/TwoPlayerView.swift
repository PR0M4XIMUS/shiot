import SwiftUI

struct TwoPlayersView: View {
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
                NotebookTitle(text: "ẞELØT", subtitle: "SH!ØT - 2 Players")
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
                        GamePlayView(
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
            .navigationTitle("2-Player Game")
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

// MARK: - Waiting View
struct WaitingForGameView: View {
    @ObservedObject var gameController: GameController
    @State private var dotCount = 1

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Game Starting")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .opacity(index < dotCount ? 1.0 : 0.3)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    dotCount = (dotCount % 3) + 1
                }
            }

            Spacer()

            HandwrittenButton("Start Game") {
                gameController.proceedToTrumpSelection()
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

// MARK: - Trump Selection View
struct TrumpSelectionView: View {
    @ObservedObject var gameController: GameController
    @Binding var selectedTrump: Suit?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if gameController.game.trumpSelectionRound == .first {
                VStack(spacing: 24) {
                    Text("Trump Offer")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    if let deckCard = gameController.game.deckCard {
                        NotebookCardDisplay(
                            card: deckCard,
                            isSelected: false,
                            action: {}
                        )
                        .frame(maxWidth: .infinity, alignment: .center)

                        Text("Revealed Card")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 16) {
                        HandwrittenButton("Accept", action: {
                            gameController.acceptTrump()
                        })

                        HandwrittenButton("Pass", action: {
                            gameController.passTrump()
                        })
                    }
                }
                .notebookCard()
            } else {
                VStack(spacing: 16) {
                    Text("Choose Trump Suit")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    VStack(spacing: 12) {
                        ForEach(Suit.allCases, id: \.self) { suit in
                            Button(action: {
                                gameController.selectCustomTrump(suit)
                            }) {
                                Text(suit.rawValue)
                                    .font(.system(size: 28, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        selectedTrump == suit ?
                                        Color.yellow.opacity(0.4) :
                                        Color.white
                                    )
                                    .border(Color.black, width: 2)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                .notebookCard()
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Game Play View
struct GamePlayView: View {
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
                        ForEach(Array(gameController.game.currentTrick.playedCards.values), id: \.id) { card in
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
                    Text("Your Hand - \(currentPlayer.hand.count) cards")
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

// MARK: - Round End View
struct RoundEndView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack(spacing: 24) {
            Text("Round Complete!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.green)
                .padding()

            VStack(spacing: 12) {
                ForEach(gameController.game.players, id: \.id) { player in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Points:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(player.totalRoundPoints)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Total Bile:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(player.totalBile)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .notebookCard()
                }
            }

            Spacer()

            HandwrittenButton("Next Round") {
                gameController.continueToNextRound()
            }
        }
        .padding()
    }
}

// MARK: - Game End View
struct GameEndView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack(spacing: 24) {
            Text("🎉 Game Over! 🎉")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.red)
                .padding()

            if let winner = gameController.game.players.max(by: { $0.totalBile < $1.totalBile }) {
                VStack(spacing: 16) {
                    Text("🏆 Winner")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    Text(winner.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)

                    Text("\(winner.totalBile) Bile")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.red)
                }
                .notebookCard()
                .pulseAnimation()

                NotebookDivider()

                Text("Final Scores")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                VStack(spacing: 12) {
                    ForEach(gameController.game.players.sorted(by: { $0.totalBile > $1.totalBile }), id: \.id) { player in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            Text("\(player.totalBile) bile")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .notebookCard()
                    }
                }
            }

            Spacer()

            NavigationLink(destination: ContentView()) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Back to Menu")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.3))
                .border(Color.black, width: 2)
                .foregroundColor(.black)
            }
        }
        .padding()
    }
}

// MARK: - Scoreboard View
struct ScoreboardView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack(spacing: 10) {
            Text("Scores")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(gameController.game.players, id: \.id) { player in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 8) {
                            Text("Round:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(player.roundScore)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }

                        HStack(spacing: 8) {
                            Text("Total:")
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

// MARK: - Card View
struct CardView: View {
    let card: Card
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(card.rank.displayName)
                    .font(.headline)
                Text(card.suit.rawValue)
                    .font(.title3)
            }
            .frame(width: 50, height: 70)
            .background(isSelected ? Color.yellow : Color.white)
            .border(isSelected ? Color.orange : Color.black, width: 2)
            .cornerRadius(4)
        }
        .foregroundColor(.black)
    }
}

#Preview {
    NavigationStack {
        TwoPlayersView(playerNames: ["Player 1", "Player 2"])
    }
}

