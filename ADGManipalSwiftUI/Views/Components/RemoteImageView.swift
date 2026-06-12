import SwiftUI
import UIKit
import ImageIO

struct RemoteImageView: View {
    var urlString: String?
    var aspectRatio: CGFloat = 1
    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    ADGTheme.surface
                    Rectangle()
                        .stroke(ADGTheme.hairline, lineWidth: 1)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .aspectRatio(aspectRatio, contentMode: .fill)
        .contentShape(Rectangle())
        .clipped()
        .task(id: urlString) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard !isLoading else { return }
        guard let urlString, let url = URL(string: urlString) else {
            loadedImage = nil
            return
        }

        if let cached = RemoteImageCache.shared.image(for: urlString) {
            loadedImage = cached
            return
        }

        if let cached = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage.downsampled(from: cached.data, maxPixelSize: 1100) {
            RemoteImageCache.shared.insert(image, for: urlString)
            loadedImage = image
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            let (data, response) = try await URLSession.shared.data(for: request)
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            let image = UIImage.downsampled(from: data, maxPixelSize: 1100)
            if let image {
                RemoteImageCache.shared.insert(image, for: urlString)
            }
            loadedImage = image
        } catch {
            loadedImage = nil
        }
    }
}

private final class RemoteImageCache {
    static let shared = RemoteImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 180
        cache.totalCostLimit = 80 * 1024 * 1024
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
}

private extension UIImage {
    static func downsampled(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, options) else { return nil }

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: image)
    }
}
