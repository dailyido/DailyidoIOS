import UIKit

enum URLHelper {
    /// Opens a URL, preferring Universal Links for known music services
    static func openSmartURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        // Convert Spotify custom scheme to Universal Link if needed
        let finalURL = convertToUniversalLink(url)

        // Open with universal link options for better deep linking
        UIApplication.shared.open(finalURL, options: [.universalLinksOnly: false])
    }

    /// Converts custom URL schemes to Universal Links for better reliability
    private static func convertToUniversalLink(_ url: URL) -> URL {
        let urlString = url.absoluteString

        // Convert spotify:track:xxx to https://open.spotify.com/track/xxx
        if urlString.hasPrefix("spotify:") {
            let components = urlString.replacingOccurrences(of: "spotify:", with: "").split(separator: ":")
            if components.count >= 2 {
                let type = components[0]  // track, album, playlist, etc.
                let id = components[1]
                if let universalURL = URL(string: "https://open.spotify.com/\(type)/\(id)") {
                    return universalURL
                }
            }
        }

        return url
    }
}
