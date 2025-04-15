import SwiftUI

struct InfoHelpView: View {
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.3),
                                             Color(red: 0.5, green: 0.4, blue: 0.7),
                                             Color(red: 0.8, green: 0.7, blue: 0.9)]),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About This App")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("This app was created to help players enjoy the game of Belot without always keeping track of the score and just enjoying the gameplay.")
                        .foregroundColor(.white)

                    Text("Created By")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Made with ❤️ by:")
                        .foregroundColor(.white)

                    Text("   - Saca Adrian")
                        .foregroundColor(.white)
                    Text("   - Bejenari Roman")
                        .foregroundColor(.white)
                    Text("   - Proscurchin Ivan")
                        .foregroundColor(.white)

                    Text("Support Us!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("If you enjoy this app, please consider supporting us with a donation. Every little bit helps!")
                        .foregroundColor(.white)

                    HStack {
                        Link("Donate via PayPal", destination: URL(string: "https://paypal.me/promaximus255?country.x=MD&locale.x=en_US")!)
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 5)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Help & Info")
        .foregroundColor(.white)
    }
}

#Preview {
    NavigationStack {
        InfoHelpView()
    }
}
