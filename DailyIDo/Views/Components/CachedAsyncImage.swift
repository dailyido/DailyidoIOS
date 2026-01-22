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

/// Illustration view for tips that automatically falls back to random illustrations
struct TipIllustrationView: View {
    let tip: Tip
    let size: CGFloat

    @State private var useRandomFallback = false

    private var illustrationUrl: String? {
        if useRandomFallback {
            // Get random illustration URL directly
            return RandomIllustrationService.shared.getRandomIllustrationUrl(for: tip.id)
        } else {
            return RandomIllustrationService.shared.getIllustrationUrl(for: tip)
        }
    }

    var body: some View {
        if let urlString = illustrationUrl, let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.clear
            } onFailure: {
                // If the tip's own illustration failed, try random fallback
                if !useRandomFallback && tip.hasIllustration {
                    print("DEBUG TipIllustrationView: Tip's illustration failed, falling back to random")
                    useRandomFallback = true
                }
            }
            .frame(width: size, height: size)
            .id(urlString + (useRandomFallback ? "-fallback" : ""))
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
