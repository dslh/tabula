import AppKit
import SwiftUI

/// Generates thumbnails of terminal views for the sidebar
class ThumbnailGenerator {
    static let shared = ThumbnailGenerator()

    private init() {}

    /// Generate a thumbnail from an NSView
    func generateThumbnail(from view: NSView, size: CGSize = CGSize(width: 120, height: 80)) -> NSImage? {
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            return nil
        }

        view.cacheDisplay(in: view.bounds, to: bitmap)

        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmap)

        // Resize to thumbnail size
        return resizeImage(image, to: size)
    }

    /// Resize an image to the specified size
    private func resizeImage(_ image: NSImage, to size: CGSize) -> NSImage {
        let thumbnail = NSImage(size: size)

        thumbnail.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high

        let aspectFill = calculateAspectFillRect(for: image.size, in: size)
        image.draw(in: aspectFill)

        thumbnail.unlockFocus()

        return thumbnail
    }

    /// Calculate aspect fill rectangle
    private func calculateAspectFillRect(for imageSize: CGSize, in targetSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let targetAspect = targetSize.width / targetSize.height

        var drawRect = CGRect.zero

        if imageAspect > targetAspect {
            // Image is wider than target
            drawRect.size.height = targetSize.height
            drawRect.size.width = targetSize.height * imageAspect
            drawRect.origin.x = -(drawRect.size.width - targetSize.width) / 2
            drawRect.origin.y = 0
        } else {
            // Image is taller than target
            drawRect.size.width = targetSize.width
            drawRect.size.height = targetSize.width / imageAspect
            drawRect.origin.x = 0
            drawRect.origin.y = -(drawRect.size.height - targetSize.height) / 2
        }

        return drawRect
    }

    /// Schedule periodic thumbnail updates for a terminal view
    func scheduleThumbnailUpdates(for view: NSView, interval: TimeInterval = 2.0, handler: @escaping (NSImage?) -> Void) -> Timer {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self, weak view] _ in
            guard let self = self, let view = view else { return }
            let thumbnail = self.generateThumbnail(from: view)
            DispatchQueue.main.async {
                handler(thumbnail)
            }
        }
    }
}
