//
//  CropImageViewModel.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import Foundation
import SwiftUI

class CropImageViewModel: ObservableObject {
    @Published var offsetLimit: CGSize = .zero
    @Published var offset = CGSize.zero
    @Published var lastOffset: CGSize = .zero
    @Published var scale: CGFloat = 1
    @Published var lastScale: CGFloat = 0
    @Published var imageViewSize: CGSize = .zero
    @Published var cropped: UIImage? = UIImage()    
    
    func getOffsetLimit() -> CGSize {
        var offsetLimit: CGSize = .zero
        offsetLimit.width = ((imageViewSize.width * scale) - 300) / 2
        offsetLimit.height = ((imageViewSize.height * scale) - 225) / 2
        return offsetLimit
    }
    
    func cropImage(_ inputImage: UIImage, screenSize: CGRect) throws -> UIImage {
        
        let cropRect: CGRect = CGRect(
                                x: (((self.imageViewSize.width) - (300 / self.scale)) / 2 - offset.width / self.scale),
                                y: (((self.imageViewSize.height) - (225 / self.scale)) / 2 - offset.height / self.scale),
                                width: 300 / self.scale,
                                height: 225 / self.scale)
        
        let imageViewScale = max(inputImage.size.width / screenSize.width,
                                 inputImage.size.height / screenSize.height)
        var cropZone: CGRect
        
        if inputImage.imageOrientation == .right {
            cropZone = CGRect(x: cropRect.origin.y * imageViewScale,
                              y: inputImage.size.width - (cropRect.size.width * imageViewScale) - (cropRect.origin.x * imageViewScale),
                              width: cropRect.size.height * imageViewScale,
                              height: cropRect.size.width * imageViewScale)
        } else {
            cropZone = CGRect(x: cropRect.origin.x * imageViewScale,
                                  y: cropRect.origin.y * imageViewScale,
                                  width: cropRect.size.width * imageViewScale,
                                  height: cropRect.size.height * imageViewScale)
        }
        
        let rotateImage: UIImage = inputImage.fixOrientation(og: inputImage)
        
        guard let cutImageRef: CGImage = rotateImage.cgImage?.cropping(to: cropZone) else {
            throw URLError(.badServerResponse)
        }
        
        var croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        croppedImage = croppedImage.fixOrientation(og: inputImage)
        return croppedImage
    }
    
}
