import Foundation

// MARK: - Round Score Entry
struct RoundScoreEntry: Identifiable, Codable {
    let id: UUID = UUID()
    var playerScores: [Int]  // Points from tricks for each player
    var combinations: [[Combination]] // Combinations for each player
    var notes: String = ""

    var totalScores: [Int] {
        playerScores.enumerated().map { index, score in
            score + combinations[index].reduce(0) { $0 + $1.points }
        }
    }
}

// MARK: - Combination Entry
struct Combination: Identifiable, Codable {
    let id: UUID = UUID()
    let name: String
    let points: Int
}

// MARK: - Scorekeeper Player
class ScorekeeperPlayer: ObservableObject, Identifiable {
    let id: UUID = UUID()
    let playerNumber: Int
    @Published var name: String
    @Published var roundScores: [Int] = []
    @Published var roundCombinations: [[Combination]] = []
    @Published var totalBile: Int = 0

    var totalPoints: Int {
        roundScores.enumerated().reduce(0) { total, item in
            let (index, score) = item
            let combosPoints = roundCombinations[safe: index]?.reduce(0) { $0 + $1.points } ?? 0
            return total + score + combosPoints
        }
    }

    var roundDetails: [(round: Int, points: Int, bile: Int)] {
        roundScores.enumerated().map { index, score in
            let combosPoints = roundCombinations[safe: index]?.reduce(0) { $0 + $1.points } ?? 0
            let roundPoints = score + combosPoints
            let roundBile = roundPoints / 10
            return (round: index + 1, points: roundPoints, bile: roundBile)
        }
    }

    init(name: String, playerNumber: Int) {
        self.name = name
        self.playerNumber = playerNumber
    }
}

// MARK: - Game Session
class GameSession: ObservableObject {
    @Published var players: [ScorekeeperPlayer]
    @Published var currentRound: Int = 0
    @Published var winThreshold: Int = 51
    @Published var gameHistory: [String] = []

    let playerCount: Int

    init(playerNames: [String]) {
        self.playerCount = playerNames.count
        self.players = playerNames.enumerated().map { index, name in
            ScorekeeperPlayer(name: name, playerNumber: index + 1)
        }
    }

    // MARK: - Score Management
    func addRoundScore(playerIndex: Int, points: Int) {
        guard playerIndex < players.count else { return }

        // Ensure roundScores array is sized to include currentRound
        while players[playerIndex].roundScores.count <= currentRound {
            players[playerIndex].roundScores.append(0)
        }

        // Add to the current round's score (sum multiple entries)
        players[playerIndex].roundScores[currentRound] += points

        // Ensure combinations array is properly sized
        while players[playerIndex].roundCombinations.count <= currentRound {
            players[playerIndex].roundCombinations.append([])
        }
    }

    func addCombination(playerIndex: Int, name: String, points: Int) {
        guard playerIndex < players.count else { return }

        // Ensure combinations array is properly sized
        while players[playerIndex].roundCombinations.count <= currentRound {
            players[playerIndex].roundCombinations.append([])
        }

        let combo = Combination(name: name, points: points)
        players[playerIndex].roundCombinations[currentRound].append(combo)
    }

    func removeCombination(playerIndex: Int, combinationId: UUID) {
        guard playerIndex < players.count, currentRound < players[playerIndex].roundCombinations.count else { return }
        players[playerIndex].roundCombinations[currentRound].removeAll { $0.id == combinationId }
    }

    func finishRound() {
        // Calculate bile for this round
        calculateBile(for: currentRound)
        currentRound += 1

        // Check if game should end
        if hasGameEnded() {
            endGame()
        }
    }

    private func calculateBile(for roundIndex: Int) {
        if playerCount == 2 {
            // 1v1: simple calculation
            for (index, player) in players.enumerated() {
                let roundPoints = (player.roundScores[safe: roundIndex] ?? 0) +
                                  (player.roundCombinations[safe: roundIndex]?.reduce(0) { $0 + $1.points } ?? 0)
                let bile = roundPoints / 10
                player.totalBile += bile
            }
        } else if playerCount == 4 {
            // 2v2: team-based calculation
            // Team 1: Players 0 + 2, Team 2: Players 1 + 3
            let teams = [[0, 2], [1, 3]]
            for team in teams {
                let teamPoints = team.reduce(0) { sum, playerIndex in
                    let roundPoints = (players[playerIndex].roundScores[safe: roundIndex] ?? 0) +
                                      (players[playerIndex].roundCombinations[safe: roundIndex]?.reduce(0) { $0 + $1.points } ?? 0)
                    return sum + roundPoints
                }
                let teamBile = teamPoints / 10
                for playerIndex in team {
                    players[playerIndex].totalBile += teamBile
                }
            }
        } else if playerCount == 3 {
            // 3-player special algorithm
            let roundPoints = players.map { player in
                (player.roundScores[safe: roundIndex] ?? 0) +
                (player.roundCombinations[safe: roundIndex]?.reduce(0) { $0 + $1.points } ?? 0)
            }
            let totalBile = roundPoints.reduce(0, +) / 10
            let sortedIndices = roundPoints.enumerated()
                .sorted { $0.element < $1.element }
                .map { $0.offset }

            // Non-leading players get their bile
            for i in 0..<2 {
                let bile = roundPoints[sortedIndices[i]] / 10
                players[sortedIndices[i]].totalBile += bile
            }

            // Leading player gets remainder
            let nonLeadingBile = (roundPoints[sortedIndices[0]] / 10) + (roundPoints[sortedIndices[1]] / 10)
            let leadingBile = totalBile - nonLeadingBile
            players[sortedIndices[2]].totalBile += max(0, leadingBile)
        }
    }

    func hasGameEnded() -> Bool {
        let winners = players.filter { $0.totalBile >= winThreshold }
        if winners.count == 1 {
            return true
        } else if winners.count > 1 {
            // Escalate threshold
            winThreshold += 50
            return false
        }
        return false
    }

    private func endGame() {
        if let winner = players.max(by: { $0.totalBile < $1.totalBile }) {
            gameHistory.append("\(winner.name) won with \(winner.totalBile) bile!")
        }
    }

    func resetGame() {
        currentRound = 0
        winThreshold = 51
        for player in players {
            player.roundScores.removeAll()
            player.roundCombinations.removeAll()
            player.totalBile = 0
        }
    }
}

// MARK: - Helper Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
