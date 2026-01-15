import SwiftUI

/// A cached version of AsyncImage that stores loaded images in memory
/// to prevent flashing/reloading during view re-renders
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
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
        guard let url = url, !isLoading else { return }

        // Check cache first
        if let cached = ImageCache.shared.get(for: url) {
            loadedImage = cached
            return
        }

        isLoading = true

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.set(image, for: url)
                    await MainActor.run {
                        loadedImage = image
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
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
