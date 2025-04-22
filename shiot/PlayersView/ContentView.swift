import SwiftUI

struct ContentView: View {
    @State private var numberOfPlayers: Int? = nil

    var body: some View {
        ZStack {
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            VStack {
                Spacer()
                VStack {
                    Text("ẞELØT")
                        .font(.system(size: 60, weight: .bold, design: .default))
                        .foregroundColor(.green)

                    Text("SH!ØT")
                        .font(.system(size: 35, weight: .bold, design: .default))
                        .foregroundColor(.red)
                    /* Text("made by: Saca Adrian, Bejenari Roman, Proscurchin Ivan")
                        .font(.system(size: 10, weight: .bold, design: .default))
                        .foregroundColor(.black) */
                }
                .padding(40)

                VStack {
                    NavigationLink {
                        gamemodeSelect(numberOfPlayers: 2)
                    } label: {
                        ZStack {
                            Image("scribble_button1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 100)
                                .padding()

                            Text("2 Players")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                    }

                    NavigationLink {
                        gamemodeSelect(numberOfPlayers: 3)
                    } label: {
                        ZStack {
                            Image("scribble_button2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 100)
                                .padding()

                            Text("3 Players")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                    }

                    NavigationLink {
                        gamemodeSelect(numberOfPlayers: 2)
                    } label: {
                        ZStack {
                            Image("scribble_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 100)
                                .padding()

                            Text("4 Players")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                    }
                    
                    /* Button(action: {
                                           
                                       }) {
                                           HStack {
                                               Image(systemName: "play.fill")
                                                   .font(.title2)
                                                   .foregroundStyle(.black)
                                               
                                               Text("Continue Game")
                                                   .foregroundStyle(.black)
                                           }
                                           .padding()
                                           .background(Color.blue)
                                               .cornerRadius(15)
                                       } */
                    

                    HStack {
                        Spacer()
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                        .padding()

                        Spacer()
                    }
                    .padding()
                }
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
