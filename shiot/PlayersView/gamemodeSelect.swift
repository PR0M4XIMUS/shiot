import SwiftUI

struct gamemodeSelect: View {
    let numberOfPlayers: Int
    @State private var playerNames: [String] = []
    @State private var isOption1Selected = false
    @State private var isOption2Selected = false

    init(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        _playerNames = State(initialValue: Array(repeating: "", count: numberOfPlayers))
    }

    var body: some View {
        ZStack {
            
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
            VStack {
                ForEach(0..<numberOfPlayers, id: \.self) { playerNumber in
                    HStack {
                        Text("P\(playerNumber + 1) name:").padding(.trailing, 5)
                        TextField("Enter name", text: $playerNames[playerNumber])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 5)
                    }
                    .padding(.bottom, 10) 
                }
                
                HStack {
                    Toggle(isOn: $isOption1Selected) {
                                    Text("Bochika")
                            
                                }.padding()
                                

                                Toggle(isOn: $isOption2Selected) {
                                    Text("Tiomka")
                           
                                }.padding()
                                
                }
                
                
                NavigationLink {
                    TwoPlayersView()// need to add the logic for when i press only the 2 Players button, it should send me here
                    } label: {
                        
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .isDetailLink(false)
                
            }
            .padding(.horizontal, 90)
            .onAppear {
                playerNames = Array(repeating: "", count: numberOfPlayers)
                
            }
            
            
        }
        
        
        
    }
}

#Preview {
    NavigationStack {
        gamemodeSelect(numberOfPlayers: 3)
    }
}
