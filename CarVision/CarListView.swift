//
//  CarListView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 03/09/2024.
//

import SwiftUI

struct CarListView<Content: View>: View {
    @ObservedObject var user: User
    var title: String
    var cars: [Car]
    @ViewBuilder let emptyView: Content
    @Namespace var imageAnimation
    @Namespace var textAnimation
    @FocusState var focused
    @State private var selectedCar: Car = Car()
    @State private var searchText = ""
    @State private var showDetail = false
    private var filteredCars: [Car] {
        searchText.isEmpty ? cars : cars.filter { car in
            car.brand.localizedCaseInsensitiveContains(searchText) || car.model.localizedCaseInsensitiveContains(searchText)
        }
    }
    var body: some View {
        if user.isShowingDetail {
            CarDetailView(user: user, car: selectedCar, imageAnimation: imageAnimation, textAnimation: textAnimation)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation {
                                user.isShowingDetail = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text(title)
                            }
                        }
                    }
                }
        } else {
            VStack {
                HStack {
                    Text(title)
                        .font(.largeTitle.bold())
                    Spacer()
                }
                .padding()
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText)
                        .focused($focused)
                        .submitLabel(.search)
                    Spacer()
                    if !searchText.isEmpty || focused {
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                searchText = ""
                                focused.toggle()
                            }
                    }
                }
                .foregroundStyle(.gray)
                .padding(5)
                .background(.thickMaterial)
                .clipShape(Capsule())
                if filteredCars.isEmpty {
                    emptyView
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [.init(), .init()]) {
                            ForEach(filteredCars, id: \.id) { car in
                                ZStack(alignment: .bottom) {
                                    Image(uiImage: car.image ?? UIImage())
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .matchedGeometryEffect(id: car.id, in: imageAnimation)
                                    Text("\(car.brand) \(car.model)")
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                        .padding(.vertical, 5)
                                        .matchedGeometryEffect(id: car.id, in: textAnimation)
                                }
                                .padding(5)
                                .frame(width: 200, height: 150)
                                .onTapGesture {
                                    withAnimation {
                                        selectedCar = car
                                        user.isShowingDetail = true
                                    }
                                }
                            }
                        }
                    }
                    .overlay {
                        if user.isListening {
                            ZStack {
                                Color("OffWhite")
                                    .ignoresSafeArea()
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 5)
            .background(Color("OffWhite"))
        }
    }
}

#Preview {
    struct Preview: View {
        @State var car = Car()
        var body: some View {
            CarListView(user: User(), title: "Garage", cars: User().history) {
                EmptyView()
            }
        }
    }
    return Preview()
}
