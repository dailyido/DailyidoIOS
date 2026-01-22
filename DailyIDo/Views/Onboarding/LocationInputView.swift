import SwiftUI

struct LocationInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(24, geometry.size.height * 0.04))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 70, height: 70)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }

                    // Title
                    Text("Where are you getting married?")
                        .font(.custom("CormorantGaramond-Bold", size: 32))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Subtitle
                    Text("Enter the city or town below")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)

                    // Location autocomplete field
                    PlacesAutocompleteField(
                        placeholder: "Start typing a city name...",
                        selectedPlace: $viewModel.weddingTown,
                        latitude: $viewModel.weddingLatitude,
                        longitude: $viewModel.weddingLongitude,
                        autoFocus: true
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Selected location confirmation
                    if !viewModel.weddingTown.isEmpty && viewModel.weddingLatitude != nil {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)

                            Text(viewModel.weddingTown)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        }
                        .padding(.top, 10)
                    }

                    // Sunset info
                    Text("This is how we will determine the sunset time and best time for photos and other fun facts about your location")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText).opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)

                    Spacer()
                        .frame(height: 24)

                    // Continue button
                    PrimaryButton(title: "Continue", isDisabled: !viewModel.canContinue) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.nextStep()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    LocationInputView(viewModel: OnboardingViewModel())
}
