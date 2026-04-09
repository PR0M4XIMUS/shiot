import Foundation

// MARK: - Suit and Rank
enum Suit: String, CaseIterable, Codable {
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"
    case spades = "♠"
}

enum Rank: Int, CaseIterable, Codable, Comparable {
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        }
    }
}

// MARK: - Card
struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let suit: Suit
    let rank: Rank

    init(suit: Suit, rank: Rank) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
    }

    // Equatable conformance - cards are equal if suit and rank match
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }

    /// Points value of card (without trump bonus)
    func basePoints() -> Int {
        switch rank {
        case .seven, .eight, .nine: return 0
        case .ten: return 10
        case .jack: return 2
        case .queen: return 3
        case .king: return 4
        case .ace: return 11
        }
    }

    /// Points with trump bonus
    func points(trump: Suit) -> Int {
        if suit == trump {
            switch rank {
            case .seven, .eight: return 0
            case .nine: return 14
            case .jack: return 20
            case .queen, .king, .ace: return basePoints()
            case .ten: return 10
            }
        }
        return basePoints()
    }

    var displayName: String {
        "\(rank.displayName)\(suit.rawValue)"
    }
}

// MARK: - Combination Types
enum CombinationType: String, Codable {
    case bela = "Bela"
    case tarca = "Tărcă"
    case jumatate = "Jumătate de sută"
    case suta = "Sută"
    case doisuta = "Două sute"
    case troisuta = "Trei sute"
    case fourTens = "Patru zeci"
    case fourNines = "Patru nouă"
    case fourJacks = "Patru valet"
    case fourSevens = "Patru șapte"
    case fourEights = "Patru opt"
}

struct Combination: Codable, Identifiable {
    let id: UUID = UUID()
    let type: CombinationType
    let points: Int
    let cards: [Card]

    init(type: CombinationType, points: Int, cards: [Card]) {
        self.type = type
        self.points = points
        self.cards = cards
    }
}

// MARK: - Game State
enum GamePhase {
    case waitingForPlayers
    case trumpSelection
    case dealing
    case playing
    case roundEnd
    case gameEnd
}

enum TrumpSelectionRound {
    case first  // Initial trump from deck
    case second // Players choose their own trump
}

// MARK: - Player
class Player: ObservableObject, Identifiable {
    let id: UUID
    let name: String
    let playerNumber: Int

    @Published var hand: [Card] = []
    @Published var roundScore: Int = 0
    @Published var totalScore: Int = 0
    @Published var totalBile: Int = 0
    @Published var combinations: [Combination] = []

    var combinationsPoints: Int {
        combinations.reduce(0) { $0 + $1.points }
    }

    var totalRoundPoints: Int {
        roundScore + combinationsPoints
    }

    init(name: String, playerNumber: Int) {
        self.id = UUID()
        self.name = name
        self.playerNumber = playerNumber
    }

    func reset() {
        hand.removeAll()
        roundScore = 0
        combinations.removeAll()
    }
}

// MARK: - Round
class Round {
    let roundNumber: Int
    var trump: Suit?
    var trumpPlayer: Player?
    var tricks: [Trick] = []
    var players: [Player]

    init(number: Int, players: [Player]) {
        self.roundNumber = number
        self.players = players
    }
}

// MARK: - Trick
struct Trick {
    var playedCards: [(playerIndex: Int, card: Card)] = []
    var winnerIndex: Int?
    var points: Int = 0

    mutating func playCard(playerIndex: Int, card: Card) {
        playedCards.append((playerIndex, card))
    }

    func isTrickComplete(playerCount: Int) -> Bool {
        playedCards.count == playerCount
    }
}

// MARK: - Game
class BelotGame: ObservableObject {
    @Published var players: [Player]
    @Published var currentPhase: GamePhase = .waitingForPlayers
    @Published var currentRound: Round?
    @Published var currentTrick: Trick = Trick()
    @Published var trump: Suit?
    @Published var trumpPlayer: Player?
    @Published var deck: [Card] = []
    @Published var deckCard: Card?
    @Published var completedRounds: [Int: Round] = [:]
    @Published var turnPlayerIndex: Int = 0
    @Published var dealerIndex: Int = 0
    @Published var trumpSelectionRound: TrumpSelectionRound = .first
    @Published var passedPlayers: Set<Int> = []

    let playerCount: Int
    let cardCount: Int // 24 for 2-3 players, 32 for 4 players

    init(players: [Player]) {
        self.players = players
        self.playerCount = players.count
        self.cardCount = players.count <= 3 ? 24 : 32
        initializeDeck()
    }

    // MARK: - Deck Management
    private func initializeDeck() {
        deck.removeAll()
        let cardRanks: [Rank] = cardCount == 24 ?
            [.seven, .nine, .ten, .jack, .queen, .king, .ace] :
            [.seven, .eight, .nine, .ten, .jack, .queen, .king, .ace]

        for suit in Suit.allCases {
            for rank in cardRanks {
                deck.append(Card(suit: suit, rank: rank))
            }
        }

        deck.shuffle()
    }

    func startNewRound() {
        players.forEach { $0.reset() }
        currentRound = Round(number: (completedRounds.count + 1), players: players)
        trump = nil
        trumpPlayer = nil
        currentPhase = .dealing
        trumpSelectionRound = .first
        passedPlayers.removeAll()
        currentTrick = Trick()

        dealInitialCards()
        selectInitialTrump()
    }

    // MARK: - Dealing
    private func dealInitialCards() {
        // Each player gets 5 cards initially
        var cardIndex = 0
        for _ in 0..<5 {
            for playerIndex in 0..<playerCount {
                if cardIndex < deck.count {
                    players[playerIndex].hand.append(deck[cardIndex])
                    cardIndex += 1
                }
            }
        }

        // Show the next card as trump candidate
        if cardIndex < deck.count {
            deckCard = deck[cardIndex]
            cardIndex += 1
        }
    }

    private func dealAdditionalCards() {
        guard let deckCard = deckCard else { return }

        var startIdx = 0
        if let deckCardIndex = deck.firstIndex(of: deckCard) {
            let nextIndex = deck.index(after: deckCardIndex)
            startIdx = deck.distance(from: deck.startIndex, to: nextIndex)
        }

        // Each player gets 3 more cards
        var currentIdx = startIdx

        for _ in 0..<3 {
            for playerIndex in 0..<playerCount {
                if currentIdx < deck.count {
                    players[playerIndex].hand.append(deck[currentIdx])
                    currentIdx += 1
                }
            }
        }
    }

    // MARK: - Trump Selection
    func selectInitialTrump() {
        guard let deckCard = deckCard else { return }

        // If Jack is shown, next player automatically plays in that trump
        if deckCard.rank == .jack {
            trump = deckCard.suit
            trumpPlayer = players[(dealerIndex + 1) % playerCount]
            dealAdditionalCards()
            startPlaying()
        } else {
            currentPhase = .trumpSelection
            turnPlayerIndex = (dealerIndex + 1) % playerCount
        }
    }

    func answerTrumpSelection(accepts: Bool) {
        guard turnPlayerIndex < players.count else { return }
        let player = players[turnPlayerIndex]

        if accepts {
            trump = deckCard?.suit
            trumpPlayer = player
            dealAdditionalCards()
            startPlaying()
        } else {
            passedPlayers.insert(turnPlayerIndex)

            // Check if all players have passed
            if passedPlayers.count == playerCount - 1 {
                // Second round: players choose their own trump
                trumpSelectionRound = .second
                passedPlayers.removeAll()
                turnPlayerIndex = (dealerIndex + 1) % playerCount
            } else {
                // Next player
                turnPlayerIndex = (turnPlayerIndex + 1) % playerCount
                if passedPlayers.contains(turnPlayerIndex) {
                    turnPlayerIndex = (turnPlayerIndex + 1) % playerCount
                }
            }
        }
    }

    func chooseTrump(_ suit: Suit) {
        trump = suit
        trumpPlayer = players[turnPlayerIndex]
        dealAdditionalCards()
        startPlaying()
    }

    // MARK: - Playing
    func startPlaying() {
        currentPhase = .playing
        detectCombinations()
        turnPlayerIndex = (dealerIndex + 1) % playerCount
    }

    func playCard(_ card: Card) {
        guard turnPlayerIndex < players.count else { return }
        let player = players[turnPlayerIndex]

        // Remove card from hand
        if let index = player.hand.firstIndex(of: card) {
            player.hand.remove(at: index)
        }

        // Add to trick
        currentTrick.playCard(playerIndex: turnPlayerIndex, card: card)

        // Check if trick is complete
        if currentTrick.isTrickComplete(playerCount: playerCount) {
            completeTrick()
        } else {
            turnPlayerIndex = (turnPlayerIndex + 1) % playerCount
        }
    }

    func completeTrick() {
        guard !currentTrick.playedCards.isEmpty else { return }

        let cardsInPlay = currentTrick.playedCards.map { $0.card }
        guard let firstCard = cardsInPlay.first else { return }

        let firstSuit = firstCard.suit
        var winningCard = firstCard
        var winnerIndex: Int = currentTrick.playedCards[0].playerIndex

        for (playerIndex, card) in currentTrick.playedCards {
            if isCardWinning(card, against: winningCard, firstSuit: firstSuit) {
                winningCard = card
                winnerIndex = playerIndex
            }
        }

        let points = cardsInPlay.reduce(0) { $0 + $1.points(trump: trump ?? .hearts) }
        players[winnerIndex].roundScore += points
        turnPlayerIndex = winnerIndex

        currentTrick = Trick()

        // Check if round is complete
        if players.allSatisfy({ $0.hand.isEmpty }) {
            completeRound()
        }
    }

    private func isCardWinning(_ card: Card, against: Card, firstSuit: Suit) -> Bool {
        guard let trump = trump else {
            return card.suit == against.suit && card.rank > against.rank
        }

        // If against card is trump, only higher trump can win
        if against.suit == trump {
            return card.suit == trump && card.rank > against.rank
        }

        // If card is trump and against is not, card wins
        if card.suit == trump {
            return true
        }

        // If both same suit (and not trump), higher rank wins
        if card.suit == against.suit && card.suit == firstSuit {
            return card.rank > against.rank
        }

        // Card doesn't win in any other case
        return false
    }

    // MARK: - Combination Detection
    func detectCombinations() {
        for player in players {
            player.combinations.removeAll()

            // Check for Bela (Q and K of trump)
            if let trump = trump {
                if let queen = player.hand.first(where: { $0.suit == trump && $0.rank == .queen }),
                   let king = player.hand.first(where: { $0.suit == trump && $0.rank == .king }) {
                    player.combinations.append(
                        Combination(type: .bela, points: 20, cards: [queen, king])
                    )
                }
            }

            // Check sequences by suit
            for suit in Suit.allCases {
                let suitCards = player.hand
                    .filter { $0.suit == suit }
                    .sorted { $0.rank < $1.rank }

                detectSequences(in: suitCards, suit: suit, for: player)
            }

            // Check four-of-a-kind (only once per player)
            detectFourOfAKind(in: player.hand, for: player)
        }
    }

    private func detectSequences(in cards: [Card], suit: Suit, for player: Player) {
        // Check sequences in descending order (longest first)
        let sequences = [
            ([.ace, .king, .queen, .jack, .ten], CombinationType.troisuta, 300),
            ([.ace, .king, .queen, .jack], CombinationType.doisuta, 200),
            ([.king, .queen, .jack, .ten], CombinationType.doisuta, 200),
            ([.queen, .jack, .ten, .nine], CombinationType.doisuta, 200),
            ([.ace, .king, .queen], CombinationType.suta, 100),
            ([.king, .queen, .jack], CombinationType.suta, 100),
            ([.queen, .jack, .ten], CombinationType.suta, 100),
            ([.jack, .ten, .nine], CombinationType.suta, 100),
            ([.ten, .nine, .eight], CombinationType.suta, 100),
            ([.nine, .eight, .seven], CombinationType.suta, 100),
            ([.ace, .king], CombinationType.tarca, 20),
            ([.king, .queen], CombinationType.tarca, 20),
            ([.queen, .jack], CombinationType.tarca, 20),
            ([.jack, .ten], CombinationType.tarca, 20),
            ([.ten, .nine], CombinationType.tarca, 20),
            ([.nine, .eight], CombinationType.tarca, 20),
            ([.eight, .seven], CombinationType.tarca, 20),
        ]

        for (requiredRanks, type, points) in sequences {
            if requiredRanks.allSatisfy({ rank in cards.contains { $0.rank == rank } }) {
                let combinationCards = requiredRanks.compactMap { rank in
                    cards.first { $0.rank == rank }
                }

                // Check if this is already a combination (to avoid duplicates)
                let alreadyAdded = player.combinations.contains { combo in
                    Set(combo.cards.map { $0.rank }) == Set(requiredRanks)
                }

                if !alreadyAdded {
                    player.combinations.append(
                        Combination(type: type, points: points, cards: combinationCards)
                    )
                }
                return // Only count longest sequence per suit
            }
        }
    }

    private func detectFourOfAKind(in cards: [Card], for player: Player) {
        let rankCounts = Dictionary(grouping: cards, by: { $0.rank })
            .filter { $0.value.count == 4 }

        for (rank, fourCards) in rankCounts {
            let type: CombinationType
            let points: Int

            switch rank {
            case .seven:
                type = .fourSevens
                points = 0 // Game is cancelled
                return
            case .eight:
                type = .fourEights
                points = 100
            case .nine:
                type = .fourNines
                points = 150
            case .jack:
                type = .fourJacks
                points = 200
            case .ten, .queen, .king, .ace:
                type = .fourTens
                points = 100
            }

            player.combinations.append(
                Combination(type: type, points: points, cards: fourCards)
            )
        }
    }

    // MARK: - Round End
    func completeRound() {
        currentPhase = .roundEnd

        // Apply Pasledu rule (last trick bonus)
        // Find the player who won the last trick (has the highest total score in this round, meaning they won)
        if let lastWinner = players.max(by: { $0.roundScore < $1.roundScore }) {
            lastWinner.roundScore += 10
        }

        // Calculate bile for each player
        calculateBile()
    }

    func calculateBile() {
        let totalPoints = players.reduce(0) { $0 + $1.totalRoundPoints }
        let totalBile = totalPoints / 10

        if playerCount == 2 {
            // 1v1: simple calculation, player with 0 points gets -10 bile (marked as no cards won)
            for player in players {
                let playerBile = player.totalRoundPoints / 10
                player.totalBile += playerBile

                if player.roundScore == 0 && player.combinations.isEmpty {
                    player.totalBile -= 10 // Penalty for taking no cards
                }
            }
        } else if playerCount == 4 {
            // 2v2: team-based scoring
            // Players 0,2 vs Players 1,3
            let team1Points = players[0].totalRoundPoints + players[2].totalRoundPoints
            let team2Points = players[1].totalRoundPoints + players[3].totalRoundPoints

            let team1Bile = team1Points / 10
            let team2Bile = team2Points / 10

            players[0].totalBile += team1Bile
            players[2].totalBile += team1Bile
            players[1].totalBile += team2Bile
            players[3].totalBile += team2Bile
        } else if playerCount == 3 {
            // 3-player special calculation
            // First get bile for non-trump players
            var nonTrumpBile = 0
            for (idx, player) in players.enumerated() {
                if player != trumpPlayer {
                    let bile = player.totalRoundPoints / 10
                    player.totalBile += bile
                    nonTrumpBile += bile
                }
            }

            // Trump player gets remaining bile
            if let trumpPlayer = trumpPlayer {
                let trumpBile = totalBile - nonTrumpBile
                trumpPlayer.totalBile += max(0, trumpBile)

                // If trump player has no points, penalty
                if trumpPlayer.roundScore == 0 && trumpPlayer.combinations.isEmpty {
                    trumpPlayer.totalBile -= 10
                }
            }
        }
    }

    func hasGameEnded(winThreshold: Int = 51) -> Bool {
        let winners = players.filter { $0.totalBile >= winThreshold }

        // Game ends when exactly one player exceeds the threshold
        if winners.count == 1 {
            return true
        }
        return false
    }
}
