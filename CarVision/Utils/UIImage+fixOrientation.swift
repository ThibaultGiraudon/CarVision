//
//  UIImage+fixOrientation.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import Foundation
import SwiftUI

public extension UIImage {
    func fixOrientation(og: UIImage) -> UIImage {
        
        switch og.imageOrientation {
        case .up:
            return self
        case .down:
            return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: .down)
        case .left:
            return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: .left)
        case .right:
            return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: .right)
        case .upMirrored:
            return self
        case .downMirrored:
            return self
        case .leftMirrored:
            return self
        case .rightMirrored:
            return self
        @unknown default:
            return self
        }
    }
}
