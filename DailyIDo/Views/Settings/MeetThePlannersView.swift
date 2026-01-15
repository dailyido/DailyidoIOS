import SwiftUI

struct MeetThePlannersView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 32)

                        // Planners photo
                        Image("planners")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 56)

                        // "Hi!" greeting
                        Text("Hi!")
                            .font(.custom("CormorantGaramond-Bold", size: 30))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .padding(.top, 16)

                        // "We're Heather & Jamie!"
                        Text("We're Heather & Jamie!")
                            .font(.custom("CormorantGaramond-Bold", size: 26))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .padding(.top, 2)

                        // Description
                        Text("Longtime wedding planners who've seen it all (truly!). We've curated daily planning tips from our 25+ years of experience to help you plan your wedding with confidence, clarity and a little bit of fun!")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 28)
                            .padding(.top, 14)

                        // Excited message
                        Text("We are excited to be a part of your wedding planning journey!")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .padding(.top, 10)

                        // Signatures
                        HStack(spacing: 16) {
                            Image("heather_signature")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: Constants.Colors.accent))

                            Image("jamie_signature")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        }
                        .padding(.top, 14)

                        Spacer()
                            .frame(height: 48)
                    }
                }
            }
            .navigationTitle("Meet the Planners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                }
            }
        }
    }
}

#Preview {
    MeetThePlannersView()
}
