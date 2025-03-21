//
//  User.swift
//  CarVision
//
//  Created by Thibault Giraudon on 31/08/2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class User: ObservableObject {
    @Published var history = [Car]()
    @Published var isShowingDetail = false
    @Published var isListening = false
    private var db = DataBaseViewModel()
    @Published var storage = StorageViewModel()
    static let shared = User()

    @MainActor
    func getHistory() async {
        do {
            let startTime = Date() // Démarrer le chrono
            
            self.history = try await db.fetchData()
            
            // Lancer tous les téléchargements en parallèle
            try await withThrowingTaskGroup(of: (Car, UIImage?).self) { group in
                for car in history {
                    group.addTask {
                        let image = await self.getImage(imageURL: car.imageURL)
                        return (car, image)
                    }
                }
                
                // Mettre à jour les images une fois qu'elles sont prêtes
                for try await (car, image) in group {
                    if let index = self.history.firstIndex(of: car) {
                        self.history[index].image = image
                    }
                }
            }
            
            let endTime = Date() // Fin du chrono
            let elapsedTime = endTime.timeIntervalSince(startTime)
            print("Temps de chargement avec async let: \(elapsedTime) secondes")
//            Temps de chargement séquentiel: 10.031455993652344 secondes
//            Temps de chargement parallèle: 2.7916311025619507 secondes
        } catch {
            print("Error fetching items: \(error.localizedDescription)")
        }
    }
    
    
    func loadImage(for car: Car) async {
        if let index = history.firstIndex(of: car) {
            let downloadedImage = await getImage(imageURL: car.imageURL)
            
            DispatchQueue.main.async {
                self.history[index].image = downloadedImage
            }
        }
    }
    
    func addCarToDB(car: Car) {
        do {
            try db.add(car)
        } catch {
            print(error)
        }
    }
    
    func editCar(car: Car) {
        do {
            try db.edit(car)
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func deleteCar(car: Car) async throws {
        do {
            try await storage.delete(image: car.imageURL)
            db.delete(car)
            if let index = history.firstIndex(of: car) {
                history.remove(at: index)
            }
        } catch {
            print(error)
        }
    }

    func getFavorite() -> [Car] {
        history.filter { $0.isFavorite }
    }
    
    func addCarToFav(_ car: Car) {
        if let index = history.firstIndex(of: car) {
            history[index].isFavorite = true
            Task {
                do {
                    try await db.toggleFavorite(for: car)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func removeCarFromFav(_ car: Car) {
        if let index = history.firstIndex(of: car) {
            history[index].isFavorite = false
            Task {
                do {
                    try await db.toggleFavorite(for: car)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func addCar(_ car: Car) {
        history.insert(car, at: 0)
        addCarToDB(car: car)
    }
    
    func getImage(imageURL: String) async -> UIImage? {
        if let image = await downloadImage(from: URL(string: imageURL)!) {
            return image
        }
        return nil
    }
    
    func downloadImage(from url: URL) async -> UIImage? {
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

