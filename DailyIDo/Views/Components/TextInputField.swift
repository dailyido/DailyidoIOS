import SwiftUI

struct TextInputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    var autoFocus: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .focused($isFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.3), lineWidth: 1.5)
                )
        }
        .task {
            if autoFocus {
                // Delay to ensure view transition animation completes and view is ready
                try? await Task.sleep(nanoseconds: 500_000_000)
                isFocused = true
            }
        }
    }
}

struct SecureInputField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool
    @State private var isSecure = true

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 17))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 17))
                    .focused($isFocused)
            }

            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.3), lineWidth: 1.5)
        )
    }
}

struct LabeledInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: Constants.Colors.secondaryText))

            TextInputField(placeholder: placeholder, text: $text, keyboardType: keyboardType)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        TextInputField(placeholder: "Your name", text: .constant(""))
        SecureInputField(placeholder: "Password", text: .constant(""))
        LabeledInputField(label: "Email Address", placeholder: "email@example.com", text: .constant(""))
    }
    .padding()
}
