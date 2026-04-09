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
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("ẞELØT - SH!ØT")
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

                // Scoreboard
                ScoreboardView(gameController: gameController)
            }
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

    var body: some View {
        VStack {
            Spacer()
            Text("Game Starting...")
                .font(.title)
            Spacer()
            Button("Start") {
                gameController.proceedToTrumpSelection()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
    }
}

// MARK: - Trump Selection View
struct TrumpSelectionView: View {
    @ObservedObject var gameController: GameController
    @Binding var selectedTrump: Suit?

    var body: some View {
        VStack {
            Spacer()

            if gameController.game.trumpSelectionRound == .first {
                VStack(spacing: 16) {
                    if let deckCard = gameController.game.deckCard {
                        Text("Card revealed: \(deckCard.displayName)")
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(8)
                    }

                    HStack(spacing: 20) {
                        Button("Accept Trump") {
                            gameController.acceptTrump()
                        }
                        .buttonStyle(.bordered)

                        Button("Pass") {
                            gameController.passTrump()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else {
                Text("Choose Trump Suit")
                    .font(.headline)
                    .padding()

                HStack(spacing: 12) {
                    ForEach(Suit.allCases, id: \.self) { suit in
                        Button(suit.rawValue) {
                            gameController.selectCustomTrump(suit)
                        }
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTrump == suit ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    }
                }
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
                    Text("Current: \(currentPlayer.name)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    if currentPlayer.combinations.count > 0 {
                        Text("Combinations: \(currentPlayer.combinations.count)")
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
                    Text("Your hand:")
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

// MARK: - Round End View
struct RoundEndView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack {
            Text("Round Complete!")
                .font(.title)
                .padding()

            VStack(spacing: 12) {
                ForEach(gameController.game.players, id: \.id) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(player.totalRoundPoints) pts")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()

            Spacer()

            Button("Next Round") {
                gameController.continueToNextRound()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
    }
}

// MARK: - Game End View
struct GameEndView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack {
            Text("Game Over!")
                .font(.title)
                .padding()

            if let winner = gameController.game.players.max(by: { $0.totalBile < $1.totalBile }) {
                VStack(spacing: 20) {
                    Text("Winner: \(winner.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("\(winner.totalBile) Bile")
                        .font(.headline)

                    VStack(spacing: 12) {
                        ForEach(gameController.game.players, id: \.id) { player in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Text("\(player.totalBile) bile")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }

            Spacer()

            NavigationLink("Back to Menu") {
                ContentView()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
    }
}

// MARK: - Scoreboard View
struct ScoreboardView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack(spacing: 8) {
            ForEach(gameController.game.players, id: \.id) { player in
                HStack {
                    Text(player.name)
                        .font(.headline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Round: \(player.roundScore)")
                            .font(.caption)
                        Text("Total: \(player.totalBile) bile")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
    }
}

// MARK: - Card View
struct CardView: View {
    let card: Card
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
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

