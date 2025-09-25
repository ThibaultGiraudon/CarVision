//
//  CropImageView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 01/09/2024.
//

import SwiftUI
import Foundation
import UIKit

struct CropImageView: View {
	@Binding var image: UIImage?
    var save: (_ image: UIImage) -> Void

    @ObservedObject var vm = CropImageViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var croppedImage = UIImage()
	var body: some View {
        
        let dragGeometry = DragGesture()
                .onChanged { gesture in
                    vm.offsetLimit = vm.getOffsetLimit()
                    
                    let width = min(
                        max(-vm.offsetLimit.width, vm.lastOffset.width + gesture.translation.width),
                        vm.offsetLimit.width
                    )
                    let height = min(
                        max(-vm.offsetLimit.height, vm.lastOffset.height + gesture.translation.height),
                        vm.offsetLimit.height
                    )
                    
                    vm.offset = CGSize(width: width, height: height)
                }
                .onEnded { value in
                    vm.lastOffset = vm.offset
                }
        
        let scaleGesture = MagnifyGesture()
                .onChanged { gesture in
                    let scaledValue = (gesture.magnification - 1) * 0.5 + 1
                    vm.scale = min(max(scaledValue * vm.lastScale, 300 / vm.imageViewSize.width), 5)
                }
                .onEnded { _ in
                    vm.lastScale = vm.scale
                    vm.lastOffset = vm.offset
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
                    .scaleEffect(vm.scale)
                    .offset(vm.offset)
			}
			.blur(radius: 20)
			
			Image(uiImage: image!)
				.resizable()
				.scaledToFit()
                .scaleEffect(vm.scale)
                .offset(vm.offset)
				.mask(
					Rectangle()
						.frame(width: 300, height: 225)
				)
				.overlay {
					Rectangle()
						.stroke(Color.white, lineWidth: 1)
						.frame(width: 300, height: 225)
				}
                .simultaneousGesture(dragGeometry)
                .simultaneousGesture(scaleGesture)
        }
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
                    do {
                        if let image = image {
                            croppedImage = try vm.cropImage(image, screenSize: UIScreen.main.bounds)
                        }
                        save(croppedImage)
                        dismiss()
                    } catch {
                        print(error)
                    }
				}) {
					Image(systemName: "checkmark.circle")
				}
			}
		}
		.onAppear {
			let factor = UIScreen.main.bounds.width / image!.size.width
            vm.imageViewSize.height = image!.size.height * factor
            vm.imageViewSize.width = image!.size.width * factor
		}
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


