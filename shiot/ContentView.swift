import SwiftUI





// Roma si Vanea, ne trogati moi cod

struct ContentView: View {
    var body: some View {
        ZStack {
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
            
            VStack {
                Spacer()
                VStack {
                    
                    
                    Text("BELØT")
                        .font(.system(size: 60, weight: .bold, design: .default))
                        .foregroundColor(.green)
                    
                    Text("SH!ØT")
                        .font(.system(size: 35, weight: .bold, design: .default))
                        .foregroundColor(.red)
                    
                    
                }.padding(40)
                
                
                VStack {
                    
                    
                    
                    NavigationLink {
                        TwoPlayersView()
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



                    
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Image("scribble_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 100)
                                .padding()
                            
                            Text("3 Players")
                                .foregroundStyle(.black)
                                .font(.headline)
                                
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Image("scribble_button2")
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
                        Button(action: {
                            print("Button tapped!")
                        }) {
                            Image(systemName: "gear.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }.padding()
                        
                        
                        Button(action: {
                            print("Button tapped!")
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }.padding()
                        Spacer()
                    }.padding()
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


