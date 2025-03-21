//
//  StorageViewModel.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import Foundation
import SwiftUI
import FirebaseStorage

class StorageViewModel {
    let storage = Storage.storage()
    
    func upload(_ image: UIImage) async throws -> String {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let new_id = UUID().uuidString
        let imageRef = storageRef.child("cars/\(new_id).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let data = image.pngData() else {
            throw URLError(.badURL)
        }
        
        _ = try await imageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    func delete(image: String) async throws {
        try await Storage.storage().reference(forURL: image).delete()
    }
}
