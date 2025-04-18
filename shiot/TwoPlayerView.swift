import SwiftUI

struct TwoPlayersView: View{
    var body: some View{
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                
                VStack(){
                    ScrollView{
                        HStack{
                            VStack{
                                
                                ForEach(1..<21) { index in
                                    Text("\(index)")
                                        .frame(height: 30)
                                }
                            }
                            .padding(.init(top: 30, leading: 0, bottom: 0, trailing: 30))
                            
                            VStack{
                                Text("Player 1")
                                ForEach(1..<21) { index in
                                    TextField("\(index)", text: .constant(""))
                                        .frame(height: 30)
                                }
                            }
                            .frame(width: 130)
                            VStack{
                                Text("Player 2")
                                ForEach(1..<21) { index in
                                    TextField("\(index)", text: .constant(""))
                                        .frame(height: 30)
                                }
                            }
                            .frame(width:130)
                        }
                    }
                    Spacer()

                    
                    HStack{
                        Text("Score: ")
                            .position(CGPoint(x: .bitWidth, y: 0))
                        Text("Score: ")
                            .position(CGPoint(x: .bitWidth, y: 0))
                    }
                    .padding()
                    .frame(minHeight: 0, maxHeight: 50)
                }
                    
                
                .navigationTitle("Two Players game")
                .padding()
                
                
            }
        }
}

#Preview {
    NavigationStack {
        TwoPlayersView()
    }
}

