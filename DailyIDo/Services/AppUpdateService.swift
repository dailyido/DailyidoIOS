import Foundation

struct AppUpdateService {
    private static let appStoreId = "6757710079"
    private static let lastPromptedVersionKey = "lastPromptedUpdateVersion"

    /// Check if a newer version is available on the App Store.
    /// Returns the new version string if an update is available, nil otherwise.
    static func checkForUpdate() async -> String? {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appStoreId)&country=us") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let storeVersion = results.first?["version"] as? String else {
                return nil
            }

            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

            // Compare versions: only prompt if store version is newer
            if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                // Only prompt once per version
                let lastPrompted = UserDefaults.standard.string(forKey: lastPromptedVersionKey)
                if lastPrompted == storeVersion {
                    return nil
                }
                return storeVersion
            }
        } catch {
            print("[AppUpdate] Error checking for update: \(error)")
        }

        return nil
    }

    /// Mark a version as prompted so we don't show the popup again for it.
    static func markVersionPrompted(_ version: String) {
        UserDefaults.standard.set(version, forKey: lastPromptedVersionKey)
    }
}
