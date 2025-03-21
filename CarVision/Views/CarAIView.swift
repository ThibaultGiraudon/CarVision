//
//  CarDetailView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 29/08/2024.
//

import SwiftUI
import UIKit
import GoogleGenerativeAI
import FirebaseFirestore
import FirebaseStorage

struct CarAIView: View {
    @StateObject var vm: CarViewModel
    @Environment(\.dismiss) var dismiss
	let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    var body: some View {
        ScrollView(showsIndicators: false) {
            Image(uiImage: vm.uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top)
            VStack {
                if let result = vm.analyzedResult {
                    Text(result)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if !vm.isAnalyzing {
                    Text("\(vm.car.brand) \(vm.car.model)")
                        .titleStyle(false)
                    LazyVGrid(columns: [.init(), .init()]) {
                        carInfo(title: "Power", info: vm.car.horsepower)
                        carInfo(title: "Speed", info: vm.car.speed)
                        carInfo(title: "Acceleration", info: vm.car.acceleration)
                        carInfo(title: "Color", info: vm.car.colorName)
                        carInfo(title: "Displacement", info: vm.car.displacement)
                        carInfo(title: "Cylinders", info: vm.car.cylinders)
                        carInfo(title: "Architecure", info: vm.car.architecture)
                        carInfo(title: "Turbo", info: vm.car.turbo)
                    }
                    Spacer()
                    Button {
                        Task {
                            try await User.shared.deleteCar(car: vm.car)
                        }
                        dismiss()
                    } label: {
                        Text("Delete")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .overlay {
                if vm.isAnalyzing {
                    VStack {
                        Spacer()
                        ProgressView()
                    }
                    .frame(height: 200)
                }
            }
        }
        .onAppear {
            print("I'm here")
            vm.analyze()
        }
        .padding(.horizontal)
        .background(Color("OffWhite"))
    }
	
	@ViewBuilder
	func carInfo(title: String, info: String) -> some View {
		VStack(alignment: .leading) {
			Text(info)
			Text(title)
				.font(.caption)
				.foregroundStyle(.gray)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
        .titleStyle(vm.isAnalyzing)
	}
}

#Preview {
    CarAIView(vm: CarViewModel(uiImage: UIImage(named: "example")!))
}
