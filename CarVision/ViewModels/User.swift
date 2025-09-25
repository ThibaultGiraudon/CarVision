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
            
            await withTaskGroup(of: Void.self) { group in
                for car in history {
                    group.addTask {
                        await self.loadImage(for: car)
                    }
                }
            }
            
            let endTime = Date() // Fin du chrono
            let elapsedTime = endTime.timeIntervalSince(startTime)
            print("Temps de chargement parallèle: \(elapsedTime) secondes")
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
    
    func toggleFav(for car: Car) {
        if let index = history.firstIndex(of: car) {
            history[index].isFavorite.toggle()
            Task {
                do {
                    try await db.toggleFavorite(for: history[index])
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

