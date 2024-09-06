//
//  CarDetailView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 03/09/2024.
//

import SwiftUI

struct CarDetailView: View {
    @ObservedObject var user: User
    @State var car: Car
    var uiImage: UIImage?
    let imageAnimation: Namespace.ID
    let textAnimation: Namespace.ID
    @State var isFavorite = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView {
            Image(uiImage: car.image ?? UIImage())
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            .matchedGeometryEffect(id: car.id, in: imageAnimation)
            Text("\(car.brand) \(car.model)")
                .titleStyle(false)
                .matchedGeometryEffect(id: car.id, in: textAnimation)
            LazyVGrid(columns: [.init(), .init()]) {
                carInfo(title: "Power", info: car.horsepower)
                carInfo(title: "Speed", info: car.speed)
                carInfo(title: "Acceleration", info: car.acceleration)
                carInfo(title: "Color", info: car.colorName)
                carInfo(title: "Displacement", info: car.displacement)
                carInfo(title: "Cylinders", info: car.cylinders)
                carInfo(title: "Architecure", info: car.architecture)
                carInfo(title: "Turbo", info: car.turbo)
            }
            Spacer()
            Button {
                Task {
                    try await user.deleteCar(car: car)
                }
                user.isShowingDetail = false
            } label: {
                Text("Delete")
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .background(Color("OffWhite"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFavorite ? user.removeCarFromFav(car) : user.addCarToFav(car)
                    isFavorite.toggle()
                } label: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(isFavorite ? .yellow: .gray)
                }
            }
        }
        .onAppear {
            isFavorite = car.isFavorite
        }
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
        .titleStyle(false)
    }
}

#Preview {
    NavigationStack {
        CarDetailView(user: User(), 
                      car: Car(brand: "BMW",
                               model: "m4",
                               horsepower: "510",
                               speed: "305km\\h",
                               acceleration: "2,8",
                               colorName: "isle of the green",
                               displacement: "3L",
                               cylinders: "6",
                               architecture: "Inline-6",
                               turbo: "twinturbo",
                               imageURL: "gs://carvision-b337f.appspot.com/IMG_2572.jpeg"),
                      imageAnimation: Namespace().wrappedValue,
                      textAnimation: Namespace().wrappedValue)
    }
}
