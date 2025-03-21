//
//  View+titleStyle.swift
//  CarVision
//
//  Created by Thibault Giraudon on 20/03/2025.
//

import Foundation
import SwiftUI

struct Title: ViewModifier {
    var isAnalyzing: Bool
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)
                }
            }
    }
}

extension View {
    func titleStyle(_ isAnalyzing: Bool) -> some View {
        modifier(Title(isAnalyzing: isAnalyzing))
    }
}
