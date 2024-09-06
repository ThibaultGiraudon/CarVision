//
//  Car.swift
//  CarVision
//
//  Created by Thibault Giraudon on 31/08/2024.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

class ViewModel: ObservableObject {
    @Published var image = UIImage()
    var imageURL: String
    
    init(imageURL: String) {
        self.imageURL = imageURL
    }
    
    func getImage() async -> UIImage? {
        if let image = await loadImage(from: URL(string: self.imageURL)!) {
            self.image = image
            return image
        }
        return nil
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                return downloadedImage
            }
        } catch {
            print("Error downloading image: \(error)")
        }
        return nil
    }
}

struct Car: Equatable, Identifiable, Codable {
    var id = UUID().uuidString
	let brand: String
	let model: String
	let horsepower: String
	let speed: String
	let acceleration: String
	let colorName: String
    let displacement: String
    let cylinders: String
    let architecture: String
    let turbo: String
    var imageURL: String
    var image: UIImage?
    var isFavorite: Bool
	
    init(brand: String, model: String, horsepower: String, speed: String, acceleration: String, colorName: String, displacement: String, cylinders: String, architecture: String, turbo: String, imageURL: String) {
		self.brand = brand
		self.model = model
		self.horsepower = horsepower
		self.speed = speed
		self.acceleration = acceleration
		self.colorName = colorName
        self.architecture = architecture
        self.displacement = displacement
        self.cylinders = cylinders
        self.turbo = turbo
        self.imageURL = imageURL
        self.isFavorite = false
	}
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.brand = try container.decode(String.self, forKey: .brand)
        self.model = try container.decode(String.self, forKey: .model)
        self.horsepower = try container.decode(String.self, forKey: .horsepower)
        self.speed = try container.decode(String.self, forKey: .speed)
        self.acceleration = try container.decode(String.self, forKey: .acceleration)
        self.colorName = try container.decode(String.self, forKey: .colorName)
        self.displacement = try container.decode(String.self, forKey: .displacement)
        self.cylinders = try container.decode(String.self, forKey: .cylinders)
        self.architecture = try container.decode(String.self, forKey: .architecture)
        self.turbo = try container.decode(String.self, forKey: .turbo)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }
    
    mutating func loadImage() async {
        let vm = ViewModel(imageURL: self.imageURL)
        self.image = await vm.getImage()
    }
	
	init() {
		self.brand = ""
		self.model = ""
		self.horsepower = ""
		self.speed = ""
		self.acceleration = ""
		self.colorName = ""
        self.architecture = ""
        self.displacement = ""
        self.cylinders = ""
        self.turbo = ""
        self.imageURL = ""
        self.isFavorite = false
	}
    
    enum CodingKeys: CodingKey {
        case brand, model, horsepower, speed, acceleration, colorName, architecture, displacement, cylinders, turbo, imageURL, isFavorite, id
    }
}
