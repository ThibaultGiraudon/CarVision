//
//  Tab.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case garage, gallery, history
    
    var id: String {
        self.rawValue
    }
    
    func name() -> String {
        switch self {
        case .garage:
            return "Garage"
        case .gallery:
            return ""
        case .history:
            return "History"
        }
    }
    
    func imageName() -> String {
        switch self {
        case .garage:
            return "door.garage.open"
        case .history:
            return "clock"
        case .gallery:
            return "photo.badge.plus"
        }
    }
}
