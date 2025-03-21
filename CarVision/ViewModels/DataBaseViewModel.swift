//
//  DataBaseViewModel.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class DataBaseViewModel {
    let db = Firestore.firestore()
    
    func fetchData() async throws -> [Car] {
        let snapshot = try await db.collection("cars").getDocuments()
        let docs = snapshot.documents
        let items = docs.compactMap {
            try? $0.data(as: Car.self)
        }
        
        return items
    }
    
    func add(_ car: Car) throws {
        try db.document("cars/\(car.id)").setData(from: car)
    }
    
    func edit(_ car: Car) throws {
        try db.document("cars/\(car.id)").setData(from: car)
    }
    
    func delete(_ car: Car) {
        db.document("cars/\(car.id)").delete()
    }
    
    func toggleFavorite(for car: Car) async throws {
        try db.document("cars/\(car.id)").setData(from: car)
    }
    
}
