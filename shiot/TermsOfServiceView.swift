import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Paper background
            Image("paper_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
                
                ScrollView {
                        
                        Group {
                            TermsSection(title: "1. Acceptance of Terms", content: "By downloading, installing, or using the BELOT SH!OT app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.")
                            
                            TermsSection(title: "2. Game Rules", content: "BELOT SH!OT is a card game application that follows traditional Belot rules. The app is intended for entertainment purposes only.")
                            
                            TermsSection(title: "3. User Restrictions", content: "Users must be of legal age to play card games in their jurisdiction. The app is not intended for gambling purposes, and no real money is involved.")
                            
                            TermsSection(title: "4. Privacy Policy", content: "We respect your privacy and protect any personal data collected. The app may collect anonymous usage data to improve user experience.")
                            
                            TermsSection(title: "5. Intellectual Property", content: "All content, artwork, code, and design elements in the BELOT SH!OT app are owned by the developers. Unauthorized reproduction or distribution is prohibited.")
                        }
                        
                        Group {
                            TermsSection(title: "6. Disclaimer", content: "The app is provided 'as is' without warranties of any kind. The developers are not liable for any issues arising from the use of this app.")
                            
                            TermsSection(title: "7. Updates", content: "These terms may be updated at any time. Continued use of the app after changes constitutes acceptance of the revised terms.")
                            
                            TermsSection(title: "8. Contact", content: "For questions regarding these Terms of Service, please contact the developers through the Help & Support section.")
                        }
                        
                        Text("Last Updated: April 2025")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    }
                    .padding(25)
                    // Removed white opacity background
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    .frame(maxWidth: 550)
                    .frame(maxWidth: .infinity)
                }
            }
        }

struct TermsSection: View {
    var title: String
    var content: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(content)
                .font(.body)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
