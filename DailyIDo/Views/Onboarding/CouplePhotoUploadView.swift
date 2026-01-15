import SwiftUI
import PhotosUI

struct CouplePhotoUploadView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(30, geometry.size.height * 0.08))

                    // Photo preview or placeholder
                    ZStack {
                        if let image = viewModel.couplePhoto {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(hex: Constants.Colors.accent), lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        } else {
                            // Placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                                    .frame(width: 180, height: 180)

                                if isLoadingPhoto {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 44))
                                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))

                                        Text("Add Photo")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                    }
                                }
                            }
                        }
                    }

                    // Title
                    Text("Add a photo of you two!")
                        .font(.custom("CormorantGaramond-Bold", size: 32))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    // Subtitle
                    Text("This will personalize your wedding countdown experience")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 10)

                    // Photo picker button
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.couplePhoto == nil ? "photo.badge.plus" : "arrow.triangle.2.circlepath")
                                .font(.system(size: 18))

                            Text(viewModel.couplePhoto == nil ? "Choose from Library" : "Change Photo")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: Constants.Colors.buttonPrimary), lineWidth: 1.5)
                        )
                    }
                    .padding(.top, 20)
                    .onChange(of: selectedItem) { newItem in
                        loadPhoto(from: newItem)
                    }

                    Spacer()
                        .frame(height: max(30, geometry.size.height * 0.08))

                    // Buttons
                    VStack(spacing: 12) {
                        // Continue button
                        PrimaryButton(
                            title: "Continue",
                            isDisabled: viewModel.couplePhoto == nil
                        ) {
                            viewModel.saveCouplePhoto()
                            viewModel.nextStep()
                        }

                        // Skip button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            viewModel.nextStep()
                        }) {
                            Text("Skip for now")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        isLoadingPhoto = true

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    viewModel.couplePhoto = image
                    isLoadingPhoto = false
                    HapticManager.shared.success()
                }
            } else {
                await MainActor.run {
                    isLoadingPhoto = false
                }
            }
        }
    }
}

#Preview {
    CouplePhotoUploadView(viewModel: OnboardingViewModel())
}
