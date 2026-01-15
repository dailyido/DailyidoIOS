import Foundation

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = true

    private let userDefaultsKey = "currentUser"
    private let supabase = SupabaseService.shared

    private init() {
        loadUserFromStorage()
    }

    private func loadUserFromStorage() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true

            // Ensure user exists in Supabase (for users created before sync was added)
            Task {
                await ensureUserExistsInSupabase(user)
            }
        }
        self.isLoading = false
    }

    private func ensureUserExistsInSupabase(_ user: User) async {
        print("🔄 [Auth] Ensuring user exists in Supabase: \(user.id)")
        do {
            try await supabase.createUser(user)
            print("✅ [Auth] User synced to Supabase: \(user.id)")
        } catch {
            print("⚠️ [Auth] Failed to sync user to Supabase: \(error)")
        }
    }

    private func saveUserToStorage(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func createLocalUser() async {
        let newUser = User(id: UUID())

        await MainActor.run {
            self.currentUser = newUser
            self.isAuthenticated = true
            saveUserToStorage(newUser)
        }

        // Also create in Supabase so foreign keys work
        do {
            try await supabase.createUser(newUser)
            print("✅ [Auth] User created in Supabase: \(newUser.id)")
        } catch {
            print("⚠️ [Auth] Failed to create user in Supabase: \(error)")
        }
    }

    func updateUser(_ user: User, silent: Bool = false) async throws {
        if silent {
            // Update storage without triggering UI refresh
            saveUserToStorage(user)
        } else {
            await MainActor.run {
                self.currentUser = user
                saveUserToStorage(user)
            }
        }

        // Also update in Supabase
        do {
            try await supabase.updateUser(user)
        } catch {
            // If update fails, try creating (user might not exist in Supabase yet)
            try await supabase.createUser(user)
        }
    }

    func refreshUser() async throws {
        // For local storage, just reload from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            await MainActor.run {
                self.currentUser = user
            }
        }
    }

    func signOut() async throws {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)

        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
}
