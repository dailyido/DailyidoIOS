import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            Color(hex: Constants.Colors.background)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button and progress
                if viewModel.currentStep > 0 && viewModel.currentStep < 12 {
                    HStack {
                        // Back button (hidden on first screen)
                        if viewModel.currentStep > 1 {
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                viewModel.previousStep()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(hex: Constants.Colors.primaryText))
                                    .frame(width: 44, height: 44)
                            }
                        } else {
                            Spacer()
                                .frame(width: 44)
                        }

                        Spacer()

                        ProgressBar(progress: Double(viewModel.currentStep) / Double(viewModel.totalSteps - 3))
                            .frame(maxWidth: 200)

                        Spacer()

                        // Placeholder for symmetry
                        Spacer()
                            .frame(width: 44)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                // Content
                TabView(selection: $viewModel.currentStep) {
                    IntroView(viewModel: viewModel)
                        .tag(0)

                    WelcomeView(viewModel: viewModel)
                        .tag(1)

                    NameInputView(viewModel: viewModel)
                        .tag(2)

                    PartnerNameInputView(viewModel: viewModel)
                        .tag(3)

                    CouplePhotoUploadView(viewModel: viewModel)
                        .tag(4)

                    DatePickerView(viewModel: viewModel)
                        .tag(5)

                    LocationInputView(viewModel: viewModel)
                        .tag(6)

                    TentedQuestionView(viewModel: viewModel)
                        .tag(7)

                    PhilosophyView(viewModel: viewModel)
                        .tag(8)

                    NotificationPermissionView(viewModel: viewModel)
                        .tag(9)

                    PreparednessView(viewModel: viewModel)
                        .tag(10)

                    RatingRequestView(viewModel: viewModel)
                        .tag(11)

                    LoadingView(viewModel: viewModel)
                        .tag(12)

                    PlanRevealView(viewModel: viewModel, isOnboardingComplete: $isOnboardingComplete)
                        .tag(13)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: Constants.Colors.buttonPrimary))
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    OnboardingContainerView(isOnboardingComplete: .constant(false))
}
