import SwiftUI

// Custom hand-drawn line
struct HandDrawnLine: View {
    var width: CGFloat
    var color: Color = .blue.opacity(0.7)
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 0))
            
            // Create slightly wavy line
            for x in stride(from: 0, to: size.width, by: 2) {
                let randomY = CGFloat.random(in: -0.8...0.8)
                path.addLine(to: CGPoint(x: x, y: randomY))
            }
            
            // End line
            path.addLine(to: CGPoint(x: size.width, y: 0))
            
            context.stroke(path, with: .color(color), lineWidth: width)
        }
        .frame(height: width + 1)
    }
}

struct NotebookBackground: View {
    var body: some View {
        ZStack {
            // Paper background
            Color(red: 0.98, green: 0.97, blue: 0.94)
                .edgesIgnoringSafeArea(.all)
            
            // Horizontal ruled lines
            VStack(spacing: 0) {
                ForEach(0..<60, id: \.self) { _ in
                    Spacer()
                    HandDrawnLine(width: 0.5, color: .blue.opacity(0.3))
                }
                Spacer()
            }
            
            // Red margin line
            HStack {
                Rectangle()
                    .fill(Color.red.opacity(0.4))
                    .frame(width: 1)
                    .padding(.leading, 25)
                Spacer()
            }
        }
    }
}

struct FourPlayerView: View {
    @ObservedObject var viewModel = FourPlayerLogic()
    
    // Custom fonts
    let handwrittenFont = Font.custom("Noteworthy", size: 18)
    let handwrittenHeadingFont = Font.custom("Noteworthy-Bold", size: 22)
    let titleFont = Font.custom("Marker Felt", size: 32)
    
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
