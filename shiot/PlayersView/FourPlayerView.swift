import SwiftUI

struct FourPlayersView: View {
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
                NotebookTitle(text: "ẞELØT", subtitle: "SH!ØT - 4 Players (2v2)")
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
                        FourPlayerGamePlayView(
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
            .navigationTitle("4-Player Game")
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

// MARK: - Four Player Game Play View
struct FourPlayerGamePlayView: View {
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
            }
        }
    }
}

struct FourPlayerView: View {
    @ObservedObject var viewModel = FourPlayerLogic()
    
    // Custom fonts - using simpler handwritten style
    let handwrittenFont = Font.custom("Bradley Hand", size: 18)
    let handwrittenHeadingFont = Font.custom("Bradley Hand", size: 22)
    let titleFont = Font.custom("MarkerFelt-Thin", size: 30)
    
    private let inputRowID = "inputRowID"
    
    var body: some View {
        NavigationView {
            ZStack {
                NotebookBackground()
                
                VStack(spacing: 0) {
                    Text("Scor Belot (4 Jucători)")
                        .font(titleFont)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom)
                        .rotationEffect(.degrees(-1))
                        .shadow(color: .gray.opacity(0.3), radius: 1, x: 1, y: 1)
                    
                    Text("Istoric Runde")
                        .font(handwrittenHeadingFont)
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.top)
                        .rotationEffect(.degrees(1))
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            Grid(
                                alignment: .center,
                                horizontalSpacing: 15,
                                verticalSpacing: 10
                            ) {
                                GridRow {
                                    Text("Echipa 1")
                                        .font(handwrittenHeadingFont)
                                        .foregroundColor(.blue.opacity(0.8))
                                        .gridColumnAlignment(.center)
                                    Text("Echipa 2")
                                        .font(handwrittenHeadingFont)
                                        .foregroundColor(.blue.opacity(0.8))
                                        .gridColumnAlignment(.center)
                                    Text("Total Rundă")
                                        .font(handwrittenHeadingFont)
                                        .foregroundColor(.blue.opacity(0.8))
                                        .gridColumnAlignment(.center)
                                    Text("")
                                        .frame(width: 30)
                                }
                                .padding(.bottom, 5)
                                
                                HandDrawnLine(width: 1.5)
                                    .gridCellUnsizedAxes([.horizontal])
                                    .padding(.vertical, 2)
                                
                                ForEach(viewModel.scores) { round in
                                    GridRow {
                                        Text("\(round.team1Score)")
                                            .font(handwrittenFont)
                                            .foregroundColor(.blue.opacity(0.9))
                                            .rotationEffect(.degrees(CGFloat.random(in: -1...1)))
                                        Text("\(round.team2Score)")
                                            .font(handwrittenFont)
                                            .foregroundColor(.blue.opacity(0.9))
                                            .rotationEffect(.degrees(CGFloat.random(in: -1...1)))
                                        Text("\(round.roundTotal)")
                                            .font(handwrittenFont)
                                            .foregroundColor(.blue.opacity(0.9))
                                            .rotationEffect(.degrees(CGFloat.random(in: -1...1)))
                                        Text("")
                                    }
                                    HandDrawnLine(width: 0.8)
                                        .gridCellUnsizedAxes([.horizontal])
                                }
                                
                                GridRow(alignment: .center) {
                                    TextField(
                                        "Scor E1",
                                        text: $viewModel.currentTeam1ScoreInput
                                    )
                                    .keyboardType(.numberPad)
                                    .font(handwrittenFont)
                                    .foregroundColor(.blue.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .frame(minHeight: 30)
                                    
                                    TextField(
                                        "Scor E2",
                                        text: $viewModel.currentTeam2ScoreInput
                                    )
                                    .keyboardType(.numberPad)
                                    .font(handwrittenFont)
                                    .foregroundColor(.blue.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .frame(minHeight: 30)
                                    
                                    TextField(
                                        "Total",
                                        text: $viewModel.currentRoundTotalInput
                                    )
                                    .keyboardType(.numberPad)
                                    .font(handwrittenFont)
                                    .foregroundColor(.blue.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .frame(minHeight: 30)
                                    
                                    Button {
                                        viewModel.saveCurrentRound(
                                            scrollProxy: scrollViewProxy
                                        )
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue.opacity(0.8))
                                            .font(.system(size: 24))
                                    }
                                    .frame(width: 30, height: 30)
                                }
                                .id(inputRowID)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                .padding(0.5)
                                        )
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    HandDrawnLine(width: 1.5)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Total Echipa 1: \(viewModel.totalTeam1)")
                            .font(handwrittenHeadingFont)
                            .foregroundColor(.blue.opacity(0.9))
                            .rotationEffect(.degrees(-0.5))
                        
                        Spacer()
                        
                        Text("Total Echipa 2: \(viewModel.totalTeam2)")
                            .font(handwrittenHeadingFont)
                            .foregroundColor(.blue.opacity(0.9))
                            .rotationEffect(.degrees(0.5))
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.yellow.opacity(0.15))
                            .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: 1)
                    )
                }
                .padding(.vertical)
                .onTapGesture {
                    viewModel.hideKeyboard()
                }
                .alert("Eroare Introducere", isPresented: $viewModel.showingInputAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }
            }
        }
    }
}

#Preview {
    FourPlayerView()
}
