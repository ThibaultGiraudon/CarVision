//
//  CropImageView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 01/09/2024.
//

import SwiftUI
import Foundation
import UIKit


public extension UIImage {
	func fixOrientation(og: UIImage) -> UIImage {
		
		switch og.imageOrientation {
		case .up:
			return self
		case .down:
			return UIImage(cgImage: cgImage!, scale: scale, orientation: .down)
		case .left:
			return UIImage(cgImage: cgImage!, scale: scale, orientation: .left)
		case .right:
			return UIImage(cgImage: cgImage!, scale: scale, orientation: .right)
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

struct CropImageView: View {
	@Binding var image: UIImage?
	@Environment(\.dismiss) var dismiss
	var save: (_ image: UIImage) -> Void
	@State private var offsetLimit: CGSize = .zero
	@State private var offset = CGSize.zero
	@State private var lastOffset: CGSize = .zero
	@State private var scale: CGFloat = 1
	@State private var lastScale: CGFloat = 0
	@State private var imageViewSize: CGSize = .zero
	@State private var cropped: UIImage? = UIImage()
	var body: some View {
		
		let dragGeometry = DragGesture()
			.onChanged { gesture in
				offsetLimit = getOffsetLimit()
				
				let width = min(
					max(-offsetLimit.width, lastOffset.width + gesture.translation.width),
					offsetLimit.width
				)
				let height = min(
					max(-offsetLimit.height, lastOffset.height + gesture.translation.height),
					offsetLimit.height
				)
				
				offset = CGSize(width: width, height: height)
			}
			.onEnded { value in
				lastOffset = offset
			}
		
		let scaleGesture = MagnifyGesture()
			.onChanged { gesture in
				let scaledValue = (gesture.magnification - 1) * 0.5 + 1
				scale = min(max(scaledValue * lastScale, 300 / imageViewSize.width), 5)
			}
			.onEnded { _ in
				lastScale = scale
				lastOffset = offset
			}
		
		ZStack(alignment: .center) {
			ZStack {
				Rectangle()
					.fill(.ultraThickMaterial)
					.ignoresSafeArea()
				Image(uiImage: image!)
					.resizable()
					.scaledToFit()
					.overlay {
						GeometryReader { geometry in
							Color.clear
						}
					}
					.scaleEffect(scale)
					.offset(offset)
			}
			.blur(radius: 20)
			
			Image(uiImage: image!)
				.resizable()
				.scaledToFit()
				.scaleEffect(scale)
				.offset(offset)
				.mask(
					Rectangle()
						.frame(width: 300, height: 225)
				)
				.overlay {
					Rectangle()
						.stroke(Color.white, lineWidth: 1)
						.frame(width: 300, height: 225)
				}
		}
		.simultaneousGesture(dragGeometry)
		.simultaneousGesture(scaleGesture)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					if let image = image {
						cropped = cropImage(
							image,
							toRect:
								CGRect(
									x: (((imageViewSize.width) - (300 / scale)) / 2 - offset.width / scale),
									y: (((imageViewSize.height) - (225 / scale)) / 2 - offset.height / scale),
									width: 300 / scale,
									height: 225 / scale),
							viewWidth: UIScreen.main.bounds.width,
							viewHeight: UIScreen.main.bounds.height)
					}
				}) {
					Image(systemName: "checkmark.circle")
				}
			}
		}
		.onAppear {
			let factor = UIScreen.main.bounds.width / image!.size.width
			imageViewSize.height = image!.size.height * factor
			imageViewSize.width = image!.size.width * factor
		}
		.onChange(of: cropped) {
			dismiss()
			save(cropped ?? UIImage())
		}
	}
	
	func getOffsetLimit() -> CGSize {
		var offsetLimit: CGSize = .zero
		offsetLimit.width = ((imageViewSize.width * scale) - 300) / 2
		offsetLimit.height = ((imageViewSize.height * scale) - 225) / 2
		return offsetLimit
	}
	
	func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
		let imageViewScale = max(inputImage.size.width / viewWidth,
								 inputImage.size.height / viewHeight)
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
			return nil
		}
		
		var croppedImage: UIImage = UIImage(cgImage: cutImageRef)
		croppedImage = croppedImage.fixOrientation(og: inputImage)
		return croppedImage
	}
	
}

#Preview {
	struct Preview: View {
		@State var image: UIImage? = UIImage(named: "example")
		func save(image: UIImage) -> Void {
		}
		var body: some View {
			NavigationStack {
				CropImageView(image: $image, save: save)
			}
		}
	}
	
	return Preview()
}


