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
	let torque: String
    let displacement: String
    let rpm: String
    let architecture: String
    let turbo: String
    var imageURL: String
    var image: UIImage?
    var isFavorite: Bool
	
    init(brand: String, model: String, horsepower: String, speed: String, acceleration: String, torque: String, displacement: String, rpm: String, architecture: String, turbo: String, imageURL: String) {
		self.brand = brand
		self.model = model
		self.horsepower = horsepower
		self.speed = speed
		self.acceleration = acceleration
		self.torque = torque
        self.architecture = architecture
        self.displacement = displacement
        self.rpm = rpm
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
		self.torque = ""
        self.architecture = ""
        self.displacement = ""
        self.rpm = ""
        self.turbo = ""
        self.imageURL = ""
        self.isFavorite = false
	}
    
    enum CodingKeys: CodingKey {
        case brand, model, horsepower, speed, acceleration, torque, architecture, displacement, rpm, turbo, imageURL, isFavorite, id
    }
}
