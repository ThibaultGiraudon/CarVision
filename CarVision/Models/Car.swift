//
//  Car.swift
//  CarVision
//
//  Created by Thibault Giraudon on 31/08/2024.
//

import SwiftUI

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
