import SwiftUI
import UIKit

struct TextInputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var uiAutocapitalization: UITextAutocapitalizationType = .words
    var autoFocus: Bool = false

    @State private var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutoFocusTextField(
                text: $text,
                placeholder: placeholder,
                keyboardType: keyboardType,
                autocapitalization: uiAutocapitalization,
                autoFocus: autoFocus,
                isFocused: $isFocused
            )
            .frame(height: 54)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.3), lineWidth: 1.5)
            )
        }
    }
}

// UIKit-based TextField for reliable auto-focus
struct AutoFocusTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .words
    var autoFocus: Bool = false
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalization
        textField.autocorrectionType = .no
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)

        // Store reference for focus attempts
        context.coordinator.textField = textField

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        // Start auto-focus attempts if needed
        if autoFocus && !context.coordinator.hasSuccessfullyFocused {
            context.coordinator.startFocusAttempts()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AutoFocusTextField
        var hasSuccessfullyFocused = false
        var focusAttemptCount = 0
        weak var textField: UITextField?

        init(_ parent: AutoFocusTextField) {
            self.parent = parent
        }

        func startFocusAttempts() {
            // Don't start if already focused or already trying
            guard !hasSuccessfullyFocused, focusAttemptCount == 0 else { return }
            attemptFocus()
        }

        private func attemptFocus() {
            focusAttemptCount += 1

            // Give up after 10 attempts (5 seconds)
            guard focusAttemptCount <= 10 else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self,
                      let textField = self.textField,
                      !self.hasSuccessfullyFocused else { return }

                // Check if textField is in window hierarchy and visible
                if textField.window != nil && textField.isUserInteractionEnabled {
                    let success = textField.becomeFirstResponder()
                    if success {
                        self.hasSuccessfullyFocused = true
                        print("✅ Auto-focus succeeded on attempt \(self.focusAttemptCount)")
                    } else {
                        // Try again
                        self.attemptFocus()
                    }
                } else {
                    // View not ready yet, try again
                    self.attemptFocus()
                }
            }
        }

        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            hasSuccessfullyFocused = true  // User focused manually
            DispatchQueue.main.async {
                self.parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
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
