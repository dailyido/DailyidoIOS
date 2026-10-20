import Foundation
import Combine

@MainActor
final class FavoritesService: ObservableObject {
    static let shared = FavoritesService()

    @Published private(set) var favoriteTipIds: Set<UUID> = []
    @Published private(set) var isLoading = false
    private(set) var favoritedDates: [UUID: Date] = [:]

    private let supabase = SupabaseService.shared
    private let authService = AuthService.shared

    private init() {}

    // MARK: - Public Methods

    /// Load favorites from Supabase
    func loadFavorites() async {
        guard let userId = authService.currentUser?.id else {
            print("💖 [Favorites] No user ID, skipping load")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            print("💖 [Favorites] Loading favorites for user: \(userId)")
            let favorites = try await supabase.fetchUserFavorites(userId: userId)
            favoriteTipIds = Set(favorites.map { $0.tipId })
            favoritedDates = Dictionary(uniqueKeysWithValues: favorites.map { ($0.tipId, $0.favoritedAt) })
            print("💖 [Favorites] Loaded \(favoriteTipIds.count) favorites: \(favoriteTipIds)")
        } catch {
            // Do NOT wipe already-loaded favorites on a transient error. Previously this
            // set favoriteTipIds = [], so a flaky network call on launch made a user's
            // saved favorites "disappear" until they force-quit and reopened the app.
            // Keep whatever we already have and just log.
            print("💖 [Favorites] Error loading (keeping existing \(favoriteTipIds.count) favorites): \(error)")
        }
    }

    /// Check if a tip is favorited
    func isFavorite(_ tipId: UUID) -> Bool {
        favoriteTipIds.contains(tipId)
    }

    /// Toggle favorite status for a tip
    /// Returns true if the tip is now favorited, false if unfavorited
    @discardableResult
    func toggleFavorite(tipId: UUID) async -> Bool {
        print("💖 [Favorites] toggleFavorite called for tipId: \(tipId)")

        guard let userId = authService.currentUser?.id else {
            print("💖 [Favorites] ERROR: No user ID found!")
            return false
        }

        print("💖 [Favorites] User ID: \(userId)")

        let wasFavorited = favoriteTipIds.contains(tipId)
        print("💖 [Favorites] Was favorited: \(wasFavorited)")

        // Optimistic update
        if wasFavorited {
            favoriteTipIds.remove(tipId)
            favoritedDates.removeValue(forKey: tipId)
        } else {
            favoriteTipIds.insert(tipId)
            favoritedDates[tipId] = Date()
        }

        // Haptic feedback
        if !wasFavorited {
            HapticManager.shared.success()
        } else {
            HapticManager.shared.buttonTap()
        }

        // Persist to database
        do {
            if wasFavorited {
                print("💖 [Favorites] Removing from Supabase: \(tipId)")
                try await supabase.removeFavorite(userId: userId, tipId: tipId)
                print("💖 [Favorites] Successfully removed from Supabase")
                AnalyticsService.shared.logTipUnfavorited(tipId: tipId)
            } else {
                print("💖 [Favorites] Adding to Supabase: \(tipId)")
                try await supabase.addFavorite(userId: userId, tipId: tipId)
                print("💖 [Favorites] Successfully added to Supabase")
                AnalyticsService.shared.logTipFavorited(tipId: tipId)
            }
        } catch {
            // Revert on failure
            print("💖 [Favorites] ERROR saving to Supabase: \(error)")
            if wasFavorited {
                favoriteTipIds.insert(tipId)
            } else {
                favoriteTipIds.remove(tipId)
            }
        }

        print("💖 [Favorites] Current favorite count: \(favoriteTipIds.count)")
        return !wasFavorited
    }

    /// Add a tip to favorites
    func addFavorite(tipId: UUID) async {
        guard !favoriteTipIds.contains(tipId) else { return }
        await toggleFavorite(tipId: tipId)
    }

    /// Remove a tip from favorites
    func removeFavorite(tipId: UUID) async {
        guard favoriteTipIds.contains(tipId) else { return }
        await toggleFavorite(tipId: tipId)
    }
}
