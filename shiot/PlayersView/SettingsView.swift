import SwiftUI

struct SettingsView: View {
    @State private var shouldNavigateToHome = false
    
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("darkMode") private var darkModeEnabled = false
    
    var body: some View {
        ZStack {
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            
            VStack {
                Text("SETTINGS")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                Spacer()
                
                ZStack {
                    Image("scribble_button")
                        .resizable()
                        .frame(width:280)
                    
                    HStack {
                        Text("Sound Effects")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Toggle("", isOn: $soundEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    .padding(.horizontal, 45)
                    .frame(width: 270)
                }
                .padding(.vertical, 5)
                
                ZStack {
                    Image("scribble_button1")
                        .resizable()
                        .frame(width: 280)
                    
                    HStack {
                        Text("Dark Mode")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Toggle("", isOn: $darkModeEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    .padding(.horizontal, 45)
                    .frame(width: 270)
                }
                .padding(.vertical, 5)
                
                NavigationLink {
                    TermsOfServiceView()
                        .navigationTitle("Terms of Service")
                } label: {
                    ZStack {
                        Image("scribble_button2")
                            .resizable()
                            .frame(width: 300)
                        
                        Text("Terms of Service")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)
                
                NavigationLink {
                    InfoHelpView()
                        .navigationTitle("Help & Support")
                } label: {
                    ZStack {
                        Image("scribble_button")
                            .resizable()
                            .frame(width: 280)
                        
                        Text("Help & Support")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)
                
                Text("Version 0.0.2")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer()
                
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
