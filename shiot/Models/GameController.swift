import Foundation

class GameController: ObservableObject {
    @Published var game: BelotGame
    @Published var gameHistory: [Int: (winner: String, bile: Int)] = [:]
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var currentWinThreshold: Int = 51

    let playerNames: [String]

    init(playerNames: [String]) {
        self.playerNames = playerNames
        let players = playerNames.enumerated().map {
            Player(name: $0.element, playerNumber: $0.offset + 1)
        }
        self.game = BelotGame(players: players)
    }

    // MARK: - Game Flow
    func startGame() {
        game.startNewRound()
    }

    func proceedToTrumpSelection() {
        guard game.currentPhase == .dealing else { return }
        game.selectInitialTrump()
    }

    func acceptTrump() {
        game.answerTrumpSelection(accepts: true)
    }

    func passTrump() {
        game.answerTrumpSelection(accepts: false)
    }

    func selectCustomTrump(_ suit: Suit) {
        game.chooseTrump(suit)
    }

    func playCard(_ card: Card) {
        // Validate play
        guard let player = game.players[game.turnPlayerIndex] else { return }
        guard player.hand.contains(card) else {
            showErrorMessage("Card not in hand")
            return
        }

        let trick = game.currentTrick
        let playedCards = Array(trick.playedCards.values)

        if let firstCard = playedCards.first {
            let isValidPlay = validateCardPlay(card, firstCard: firstCard, playerHand: player.hand)
            if !isValidPlay {
                showErrorMessage("Invalid card play. Check rules.")
                return
            }
        }

        game.playCard(card)

        // Check for special rules
        checkSpecialRules()
    }

    // MARK: - Card Play Validation
    private func validateCardPlay(_ card: Card, firstCard: Card, playerHand: [Card]) -> Bool {
        guard let trump = game.trump else { return true }

        let firstSuit = firstCard.suit
        let trumpCards = playerHand.filter { $0.suit == trump }
        let firstSuitCards = playerHand.filter { $0.suit == firstSuit }

        // Rule 1: Must play first suit if available
        if !firstSuitCards.isEmpty {
            return card.suit == firstSuit
        }

        // Rule 2: Must play trump if first suit not available and trump is in hand
        if !trumpCards.isEmpty {
            return card.suit == trump
        }

        // Rule 3: Can play anything if neither first suit nor trump available
        return true
    }

    // MARK: - Special Rules
    private func checkSpecialRules() {
        let playedCards = Array(game.currentTrick.playedCards.values)

        // Check for 8888 (cancels all combinations except Bela)
        let eights = playedCards.filter { $0.rank == .eight }
        if eights.count == 4 {
            for player in game.players {
                if player != game.trumpPlayer {
                    player.combinations.removeAll { $0.type != .bela }
                }
            }
        }

        // Check for 7777 (cancels round)
        let sevens = playedCards.filter { $0.rank == .seven }
        if sevens.count == 4 {
            cancelRound()
            return
        }
    }

    private func cancelRound() {
        // Reset all scores and start new deal
        game.players.forEach { player in
            player.roundScore = 0
            player.combinations.removeAll()
        }
        game.dealerIndex = (game.dealerIndex + 1) % game.playerCount
        game.startNewRound()
    }

    func continueToNextRound() {
        // Check if game should end with current threshold
        if game.hasGameEnded(winThreshold: currentWinThreshold) {
            endGame()
        } else {
            // Check if we need to escalate the threshold
            let playersOverThreshold = game.players.filter { $0.totalBile >= currentWinThreshold }.count
            if playersOverThreshold > 1 {
                // Escalate threshold by 50
                currentWinThreshold += 50
            }

            game.dealerIndex = (game.dealerIndex + 1) % game.playerCount
            game.completedRounds[game.currentRound?.roundNumber ?? 0] = game.currentRound
            game.startNewRound()
        }
    }

    // MARK: - Game End
    func endGame() {
        if let winner = game.players.max(by: { $0.totalBile < $1.totalBile }) {
            gameHistory[gameHistory.count + 1] = (winner: winner.name, bile: winner.totalBile)
        }
    }

    // MARK: - Error Handling
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    // MARK: - Helper Methods
    func getCurrentPlayer() -> Player? {
        guard game.turnPlayerIndex < game.players.count else { return nil }
        return game.players[game.turnPlayerIndex]
    }

    func getTrumpPlayer() -> Player? {
        game.trumpPlayer
    }

    func getScoreboardData() -> [(name: String, score: Int, bile: Int)] {
        game.players.map { ($0.name, $0.totalRoundPoints, $0.totalBile) }
    }
}
