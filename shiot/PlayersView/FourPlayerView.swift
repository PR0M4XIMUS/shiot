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
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("ẞELØT - SH!ØT (4-Player)")
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

                // Scoreboard
                ScoreboardView(gameController: gameController)
            }
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
