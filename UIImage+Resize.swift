// MARK: - UIImage Extension
// UIImage+Resize.swift

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        
        // Calculate aspect fill rect
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        let scaledWidth = self.size.width * aspectRatio
        let scaledHeight = self.size.height * aspectRatio
        let x = (size.width - scaledWidth) / 2
        let y = (size.height - scaledHeight) / 2
        
        let drawRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        UIBezierPath(rect: rect).addClip()
        self.draw(in: drawRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
