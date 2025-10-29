//
//  UIImage+Extensions.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    func cropped() -> UIImage {
        let side = min(size.width, size.height)
        let x = (size.width - side) / 2
        let y = (size.height - side) / 2
        let cropRect = CGRect(x: x, y: y, width: side, height: side)
        
        guard let cgImage = cgImage?.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
