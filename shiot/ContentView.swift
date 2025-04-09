import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack {
                
                
                Text("BELOT")
                    .font(.system(size: 60, weight: .bold, design: .default))
                    .foregroundColor(.green)
                
                Text("$H!ØT")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    .foregroundColor(.red)
                
                
            }.padding(40)
            
                        
            VStack {
                
                
                
                Button(action: {
                    
                }) {
                    Text("2 Players").foregroundStyle(Color(.black))
                        .padding()
                        .background(Color(.gray))
                        .cornerRadius(15)
                }.padding()
                
                
                
                Button(action: {
                    
                }) {
                    Text("3 Players").foregroundStyle(Color(.black))
                        .padding()
                        .background(Color(.gray))
                        .cornerRadius(15)
                }.padding()
                
                Button(action: {
                    
                }) {
                    Text("4 Players").foregroundStyle(Color(.black))
                        .padding()
                        .background(Color(.gray))
                        .cornerRadius(15)
                }.padding()
                
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

#Preview {
    ContentView()
}


