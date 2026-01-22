import Foundation

/// Service that provides random illustration URLs for tips that don't have their own illustration
final class RandomIllustrationService {
    static let shared = RandomIllustrationService()

    private var randomIllustrations: [String] = []
    private var isLoaded = false
    private let supabase = SupabaseService.shared

    private init() {}

    /// Load the list of random illustrations from Supabase storage
    func loadRandomIllustrations() async {
        guard !isLoaded else {
            print("DEBUG RandomIllustrationService: Already loaded, skipping")
            return
        }

        print("DEBUG RandomIllustrationService: Starting to load random illustrations...")
        do {
            randomIllustrations = try await supabase.listRandomIllustrations()
            isLoaded = true
            print("DEBUG RandomIllustrationService: ✅ Loaded \(randomIllustrations.count) random illustrations")
            if let first = randomIllustrations.first {
                print("DEBUG RandomIllustrationService: First file: \(first)")
            }
        } catch {
            print("DEBUG RandomIllustrationService: ❌ Failed to load random illustrations: \(error)")
            print("DEBUG RandomIllustrationService: Error details: \(String(describing: error))")
        }
    }

    /// Get an illustration URL for a tip
    /// Returns the tip's own illustration if it has one, otherwise returns a random illustration
    /// Uses the tip ID as a seed so the same tip always gets the same random image
    func getIllustrationUrl(for tip: Tip) -> String? {
        // If tip has its own illustration, use that
        if let illustrationUrl = tip.illustrationUrl, tip.hasIllustration {
            let encodedFilename = illustrationUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? illustrationUrl
            let url = "\(Constants.supabaseURL)/storage/v1/object/public/illustrations/\(encodedFilename)"
            print("DEBUG RandomIllustrationService: Using tip's own illustration: \(url)")
            return url
        }

        // Otherwise, get a random illustration (deterministic based on tip ID)
        let randomUrl = getRandomIllustrationUrl(for: tip.id)
        print("DEBUG RandomIllustrationService: Using random illustration for tip \(tip.id): \(randomUrl ?? "NIL - no random illustrations loaded")")
        return randomUrl
    }

    /// Get a deterministic random illustration URL based on an ID
    /// The same ID will always return the same illustration
    func getRandomIllustrationUrl(for id: UUID) -> String? {
        guard !randomIllustrations.isEmpty else { return nil }

        // Use the UUID to deterministically select an illustration
        // This ensures the same tip always shows the same random image
        let hashValue = abs(id.uuidString.hashValue)
        let index = hashValue % randomIllustrations.count
        let filename = randomIllustrations[index]

        let encodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
        return "\(Constants.supabaseURL)/storage/v1/object/public/illustrations_random/\(encodedFilename)"
    }

    /// Check if random illustrations are available
    var hasRandomIllustrations: Bool {
        !randomIllustrations.isEmpty
    }

    /// Force reload the illustrations list
    func reload() async {
        isLoaded = false
        await loadRandomIllustrations()
    }
}
