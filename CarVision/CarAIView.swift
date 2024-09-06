//
//  CarDetailView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 29/08/2024.
//

import SwiftUI
import UIKit
import GoogleGenerativeAI
import FirebaseFirestore
import FirebaseStorage

struct Title: ViewModifier {
	var isAnalyzing: Bool
	func body(content: Content) -> some View {
		content
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)
			.background(Color(.systemGray6))
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.overlay {
				if isAnalyzing {
					ProgressView()
						.tint(.white)
				}
			}
	}
}

extension View {
	func titleStyle(_ isAnalyzing: Bool) -> some View {
		modifier(Title(isAnalyzing: isAnalyzing))
	}
}

struct CarAIView: View {
    @ObservedObject var user: User
    @Binding var uiImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @State private var isAnalyzing: Bool = false
    @State private var analyzedResult: String?
    @State private var car: Car = Car()
    @State private var rotation = 0.0
    @State private var isFavorite = false
    @State private var imageURL = ""
	let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    var body: some View {
		if let image = uiImage {
			ScrollView(showsIndicators: false) {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top)
                VStack {
                    if let result = analyzedResult {
                        Text(result)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if !isAnalyzing {
                        Text("\(car.brand) \(car.model)")
                            .titleStyle(false)
                        LazyVGrid(columns: [.init(), .init()]) {
                            carInfo(title: "Power", info: car.horsepower)
                            carInfo(title: "Speed", info: car.speed)
                            carInfo(title: "Acceleration", info: car.acceleration)
                            carInfo(title: "Color", info: car.colorName)
                            carInfo(title: "Displacement", info: car.displacement)
                            carInfo(title: "Cylinders", info: car.cylinders)
                            carInfo(title: "Architecure", info: car.architecture)
                            carInfo(title: "Turbo", info: car.turbo)
                        }
                        Spacer()
                        Button {
                            Task {
                                try await user.deleteCar(car: car)
                            }
                            dismiss()
                        } label: {
                            Text("Delete")
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .overlay {
                    if isAnalyzing {
                        VStack {
                            Spacer()
                            ProgressView()
                        }
                        .frame(height: 200)
                    }
                }
			}
			.onAppear {
				analyze()
			}
			.padding(.horizontal)
            .background(Color("OffWhite"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        user.addCarToFav(car)
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(isFavorite ? .yellow: .gray)
                    }
                }
            }
		}
    }
	
	@ViewBuilder
	func carInfo(title: String, info: String) -> some View {
		VStack(alignment: .leading) {
			Text(info)
			Text(title)
				.font(.caption)
				.foregroundStyle(.gray)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.titleStyle(isAnalyzing)
	}

	@MainActor func analyze() {
		self.analyzedResult = nil
		self.isAnalyzing = true
		
		guard let uiImage = uiImage else {
			self.analyzedResult = "Image could not be loaded"
			self.isAnalyzing = false
			return
		}
		
		let prompt = "Provide a complete description of the car including the following details:\nCar brand.\nModel.\nHorsepower (hp).\nTop speed in km/h.\n0 to 100 km/h acceleration time in seconds.\nNumbre of cylinder.\nEngine displacement.\nEngine Layouts like flat-6.\nTurbo's architecture.\nColor code like Boston Green Metallic\nGive me each information with the unit in that order per line and nothing more"
		
		Task {
			do {
				let response = try await model.generateContent(prompt, uiImage)
				
				if let text = response.text {
					let components = text.split(separator: "\n")
					if components.count < 10 {
						self.analyzedResult = "Incorrect information provided"
						self.isAnalyzing = false
						return
					}
                    await uploadImage(uiImage)
                    let brand = components[0]
                    let model = components[1]
                    let horsepower = components[2]
                    let speed = components[3]
                    let acceleration = components[4]
                    let cylinders = components[5]
                    let displacement = components[6]
                    let architecture = components[7]
                    let turbo = components[8]
                    let colorName = components[9]
                    car = Car(brand: String(brand), model: String(model), horsepower: String(horsepower), speed: String(speed), acceleration: String(acceleration), colorName: String(colorName), displacement: String(displacement), cylinders: String(cylinders), architecture: String(architecture), turbo: String(turbo), imageURL: imageURL)
                    Task {
                        await user.loadImage(for: car)
                    }
					user.addCar(car)
				} else {
					self.analyzedResult = "No response from the model"
				}
			} catch {
				self.analyzedResult = "Error: \(error.localizedDescription)"
			}
			self.isAnalyzing = false
		}
	}
    
    @MainActor
    func uploadImage(_ image: UIImage) async {
        do {
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let new_id = UUID().uuidString
            let imageRef = storageRef.child("cars/\(new_id).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            guard let data = image.pngData() else { return }
            
            _ = try await imageRef.putDataAsync(data, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            
            self.imageURL = downloadURL.absoluteString
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

#Preview {
	struct Preview: View {
		@State var image: UIImage? = UIImage(named: "example")
		var body: some View {
			CarAIView(user: User(), uiImage: $image)
		}
	}
	
	return Preview()
}
