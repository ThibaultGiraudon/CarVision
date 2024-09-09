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

class User: ObservableObject, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    @Published var history = [Car]()
    @Published var isShowingDetail = false
    @Published var isListening = false
    
    
    let db = Firestore.firestore()

    @MainActor
    func listenToItems() async {
        do {
            let snapshot = try await db.collection("cars").getDocuments()
            let docs = snapshot.documents
            let items = docs.compactMap {
                try? $0.data(as: Car.self)
            }
            
            self.history = items
        } catch {
            print("Error fetching items: \(error.localizedDescription)")
        }
    }
    
    
    func loadImage(for car: Car) async {
        if let index = history.firstIndex(of: car) {
            let vm = ViewModel(imageURL: history[index].imageURL)
            let downloadedImage = await vm.getImage()
            
            DispatchQueue.main.async {
                self.history[index].image = downloadedImage
            }
        }
    }
    
    func addCarToDB(car: Car) {
        
        do {
            try db.document("cars/\(car.id)").setData(from: car)
        } catch {
            print(error)
        }
    }
    
    func editCar(car: Car) {
        do {
            try db.document("cars/\(car.id)").setData(from: car)
        } catch {
            print(error)
        }
    }
    
    func deleteCar(car: Car) async throws {
        do {
            try await deleteImage(car: car)
            try await db.document("cars/\(car.id)").delete()
            if let index = history.firstIndex(of: car) {
                history.remove(at: index)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteImage(car: Car) async throws {
        do {
            try await Storage.storage().reference(forURL: car.imageURL).delete()
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
            do {
                try db.document("cars/\(history[index].id)").setData(from: history[index])
            } catch {
                print(error)
            }
        }
    }
    
    func removeCarFromFav(_ car: Car) {
        if let index = history.firstIndex(of: car) {
            history[index].isFavorite = false
            do {
                try db.document("cars/\(history[index].id)").setData(from: history[index])
            } catch {
                print(error)
            }
        }
    }
    
    func addCar(_ car: Car) {
        history.insert(car, at: 0)
        addCarToDB(car: car)
    }
}

