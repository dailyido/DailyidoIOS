import SwiftUI

struct DatePickerView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.08))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }

                    // Title
                    Text("When's the big day?")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)

                    // Date picker - wheel style
                    DatePicker(
                        "",
                        selection: $viewModel.weddingDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 160)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // I don't know checkbox
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        viewModel.doesntKnowDate.toggle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.doesntKnowDate ? "checkmark.square.fill" : "square")
                                .font(.system(size: 22))
                                .foregroundColor(viewModel.doesntKnowDate ? Color(hex: Constants.Colors.buttonPrimary) : .gray)

                            Text("I don't know my wedding date yet")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        }
                    }
                    .padding(.top, 20)

                    if viewModel.doesntKnowDate {
                        Text("No worries! You can change this later in settings.")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 8)
                    }

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.08))

                    // Continue button
                    PrimaryButton(title: "Continue") {
                        viewModel.nextStep()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    DatePickerView(viewModel: OnboardingViewModel())
}
