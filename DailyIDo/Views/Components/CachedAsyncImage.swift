import SwiftUI

/// A cached version of AsyncImage that stores loaded images in memory
/// to prevent flashing/reloading during view re-renders
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    var onFailure: (() -> Void)?

    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var hasFailed = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        onFailure: (() -> Void)? = nil
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        self.onFailure = onFailure
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else if let cached = ImageCache.shared.get(for: url) {
                content(Image(uiImage: cached))
                    .onAppear {
                        loadedImage = cached
                    }
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = url, !isLoading, !hasFailed else { return }

        // Check cache first
        if let cached = ImageCache.shared.get(for: url) {
            loadedImage = cached
            return
        }

        isLoading = true

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                // Check for HTTP error status
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    await MainActor.run {
                        isLoading = false
                        hasFailed = true
                        onFailure?()
                    }
                    return
                }

                if let image = UIImage(data: data) {
                    ImageCache.shared.set(image, for: url)
                    await MainActor.run {
                        loadedImage = image
                        isLoading = false
                    }
                } else {
                    // Data received but couldn't create image
                    await MainActor.run {
                        isLoading = false
                        hasFailed = true
                        onFailure?()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    hasFailed = true
                    onFailure?()
                }
            }
        }
    }
}

/// Cache for illustration URLs - ensures the same tip always shows the same image
final class IllustrationURLCache {
    static let shared = IllustrationURLCache()

    private var cache: [UUID: String] = [:]
    private let lock = NSLock()

    private init() {}

    /// Get or compute the illustration URL for a tip (thread-safe)
    func getURL(for tip: Tip) -> String? {
        lock.lock()
        defer { lock.unlock() }

        // Return cached URL if available
        if let cached = cache[tip.id] {
            return cached
        }

        // Compute and cache the URL
        let url = RandomIllustrationService.shared.getIllustrationUrl(for: tip)
        if let url = url {
            cache[tip.id] = url
        }
        return url
    }

    /// Pre-cache a URL for a tip
    func preCache(tip: Tip) {
        _ = getURL(for: tip)
    }

    /// Clear the cache (call on logout or major state changes)
    func clear() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }
}

/// Illustration view for tips that uses cached URLs to prevent glitching
struct TipIllustrationView: View {
    let tip: Tip
    let size: CGFloat

    // Get the URL once on init and keep it stable
    private let cachedUrl: String?

    init(tip: Tip, size: CGFloat) {
        self.tip = tip
        self.size = size
        // Use the cached URL - this ensures stability during view recreation
        self.cachedUrl = IllustrationURLCache.shared.getURL(for: tip)
    }

    var body: some View {
        if let urlString = cachedUrl, let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.clear
            } onFailure: {
                // URL is cached, so failure means the image truly doesn't exist
                // Nothing to do here - the placeholder will show
            }
            .frame(width: size, height: size)
            .id(tip.id.uuidString) // Stable ID based on tip
        }
    }
}

/// Simple in-memory image cache using NSCache
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 100
    }

    func get(for url: URL?) -> UIImage? {
        guard let url = url else { return nil }
        return cache.object(forKey: url as NSURL)
    }

    func set(_ image: UIImage, for url: URL?) {
        guard let url = url else { return }
        cache.setObject(image, forKey: url as NSURL)
    }
}
