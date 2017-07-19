//
//  UIImage.swift
//
//  (c) 2016 @toddheasley
//
import UIKit
import ImageIO
extension UIImage {
    static func animatedImage(data: Data) -> UIImage? {
        guard let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 1 else {
            return UIImage(data: data)
        }
        // Collect key frames and durations
        var frames: [(image: CGImage, delay: Float)] = []
        for i: Int in 0 ..< CGImageSourceGetCount(source) {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil), let frame = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any], let gif = frame["{GIF}"] as? [String: Any] else {
                continue
            }
            // Mimic WebKit approach to determine frame delay
            if let delay = gif["UnclampedDelayTime"] as? Float, delay > 0.1 {
                frames.append((image, delay)) // Prefer "unclamped" delay time
            } else if let delay = gif["DelayTime"] as? Float, delay > 0.1 {
                frames.append((image, delay))
            } else {
                frames.append((image, 0.1)) // WebKit default
            }
        }
        // Convert key frames to animated image
        var images: [UIImage] = []
        var duration: Float = 0.0
        for frame in frames {
            let image = UIImage(cgImage: frame.image)
            for _ in 0 ..< Int(frame.delay * 100.0) {
                images.append(image) // Add fill frames
            }
            duration += frame.delay
        }
        return UIImage.animatedImage(with: images, duration: TimeInterval(duration))
    }
}
