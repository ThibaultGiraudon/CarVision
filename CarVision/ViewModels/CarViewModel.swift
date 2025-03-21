//
//  CasViewModel.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import SwiftUI
import GoogleGenerativeAI

class CarViewModel: ObservableObject {
    @Published var isAnalyzing: Bool = false
    @Published var analyzedResult: String?
    @Published var car: Car = Car()
    @Published var imageURL = ""
    var uiImage: UIImage
    
    init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    @MainActor
    func analyze() {
        self.analyzedResult = nil
        self.isAnalyzing = true
        
        let prompt = "Provide a complete description of the car including the following details:\nCar brand.\nModel.\nHorsepower (hp).\nTop speed in km/h.\n0 to 100 km/h acceleration time in seconds.\nNumbre of cylinder.\nEngine displacement.\nEngine Layouts like flat-6 or V6.\nTurbo's architecture.\nColor code like Boston Green Metallic\nGive me each information with the unit in that order per line and nothing more"
        
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
                    imageURL = try await User.shared.storage.upload(uiImage)
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
                    if !imageURL.isEmpty {
                        car = Car(brand: String(brand), model: String(model), horsepower: String(horsepower), speed: String(speed), acceleration: String(acceleration), colorName: String(colorName), displacement: String(displacement), cylinders: String(cylinders), architecture: String(architecture), turbo: String(turbo), imageURL: imageURL)
                    } else {
                        analyzedResult = "Error while uploading image please try again"
                    }
                    Task {
                        await User.shared.loadImage(for: car)
                    }
                    User.shared.addCar(car)
                } else {
                    self.analyzedResult = "No response from the model"
                }
            } catch {
                self.analyzedResult = "Error: \(error.localizedDescription)"
            }
            self.isAnalyzing = false
        }
    }
    
}
