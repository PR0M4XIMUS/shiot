import SwiftUI

struct RoundScore: Identifiable {
    let id = UUID()
    let team1Score: Int
    let team2Score: Int
    let roundTotal: Int
}

class FourPlayerLogic: ObservableObject {
    @Published var scores: [RoundScore] = []
    @Published var currentTeam1ScoreInput: String = ""
    @Published var currentTeam2ScoreInput: String = ""
    @Published var currentRoundTotalInput: String = "16"
    @Published var showingInputAlert = false
    @Published var alertMessage = ""
    
    var totalTeam1: Int {
        scores.reduce(0) { $0 + $1.team1Score }
    }
    
    var totalTeam2: Int {
        scores.reduce(0) { $0 + $1.team2Score }
    }
    
    func saveCurrentRound(scrollProxy: ScrollViewProxy) {
        hideKeyboard()
        
        let t1Text = currentTeam1ScoreInput.trimmingCharacters(in: .whitespaces)
        let t2Text = currentTeam2ScoreInput.trimmingCharacters(in: .whitespaces)
        let totalText = currentRoundTotalInput.trimmingCharacters(
            in: .whitespaces
        )
        
        var finalT1: Int?
        var finalT2: Int?
        var finalTotal: Int?
        
        if !t1Text.isEmpty && !t2Text.isEmpty && !totalText.isEmpty {
            guard let t1 = Int(t1Text), t1 >= 0 else {
                showError(
                    "Introduceți un scor valid (număr >= 0) pentru Echipa 1."
                )
                return
            }
            guard let t2 = Int(t2Text), t2 >= 0 else {
                showError(
                    "Introduceți un scor valid (număr >= 0) pentru Echipa 2."
                )
                return
            }
            guard let total = Int(totalText), total >= 0 else {
                showError(
                    "Introduceți un total valid (număr >= 0) pentru rundă."
                )
                return
            }
            guard t1 + t2 == total else {
                showError(
                    "Suma scorurilor (\(t1) + \(t2) = \(t1 + t2)) nu corespunde cu totalul rundei introdus (\(total))."
                )
                return
            }
            finalT1 = t1
            finalT2 = t2
            finalTotal = total
        } else if !t1Text.isEmpty && t2Text.isEmpty && !totalText.isEmpty {
            guard let t1 = Int(t1Text), t1 >= 0 else {
                showError(
                    "Introduceți un scor valid (număr >= 0) pentru Echipa 1."
                )
                return
            }
            guard let total = Int(totalText), total >= 0 else {
                showError(
                    "Introduceți un total valid (număr >= 0) pentru rundă."
                )
                return
            }
            let t2 = total - t1
            guard t2 >= 0 else {
                showError(
                    "Scorul calculat pentru Echipa 2 (\(t2)) este negativ. Verificați scorul Echipei 1 și totalul."
                )
                return
            }
            finalT1 = t1
            finalT2 = t2
            finalTotal = total
        } else if t1Text.isEmpty && !t2Text.isEmpty && !totalText.isEmpty {
            guard let t2 = Int(t2Text), t2 >= 0 else {
                showError(
                    "Introduceți un scor valid (număr >= 0) pentru Echipa 2."
                )
                return
            }
            guard let total = Int(totalText), total >= 0 else {
                showError(
                    "Introduceți un total valid (număr >= 0) pentru rundă."
                )
                return
            }
            let t1 = total - t2
            guard t1 >= 0 else {
                showError(
                    "Scorul calculat pentru Echipa 1 (\(t1)) este negativ. Verificați scorul Echipei 2 și totalul."
                )
                return
            }
            finalT1 = t1
            finalT2 = t2
            finalTotal = total
        } else {
            showError(
                "Introduceți fie ambele scoruri și totalul, fie scorul unei echipe și totalul."
            )
            return
        }
        
        if let t1 = finalT1, let t2 = finalT2, let total = finalTotal {
            let newRound = RoundScore(
                team1Score: t1,
                team2Score: t2,
                roundTotal: total
            )
            scores.append(newRound)
            resetInputs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    scrollProxy.scrollTo("inputRowID", anchor: .bottom)
                }
            }
        }
    }
    
    func resetInputs() {
        currentTeam1ScoreInput = ""
        currentTeam2ScoreInput = ""
        currentRoundTotalInput = "16"
    }
    
    func showError(_ message: String) {
        alertMessage = message
        showingInputAlert = true
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
