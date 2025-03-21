//
//  ContentView.swift
//  CarVision
//
//  Created by Thibault Giraudon on 29/08/2024.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var user = User.shared
    @State private var activeTab: Tab = .history
	@State private var selectedItem: PhotosPickerItem?
	@State private var selectedImage: UIImage?
	@State private var showSheet: Bool = false
	@State private var showCarDetail: Bool = false
	@State private var croppedImage: UIImage?
    var body: some View {
		ZStack(alignment: .bottom) {
            VStack {
                switch activeTab {
                case .garage:
                    CarListView(user: user, title: "Garage", cars: user.getFavorite()) {
                        ContentUnavailableView("Your garage is empty", systemImage: "door.garage.double.bay.closed.trianglebadge.exclamationmark", description: Text("First scan a car and add it to your garage"))
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
                case .gallery:
                    EmptyView()
                case .history:
                    CarListView(user: user, title: "History", cars: user.history) {
                        ContentUnavailableView("Your history is empty", systemImage: "car.side.lock.fill", description: Text("First scan a car"))
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
                
            }
            .safeAreaInset(edge: .bottom) {
                if !user.isShowingDetail {
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            if tab == .gallery {
                                PhotosPicker(selection: $selectedItem) {
                                    Image(systemName: "photo.badge.plus")
                                        .foregroundStyle(Color("DimGray"))
                                        .padding(25)
                                        .background(Color("OffWhite"))
                                        .clipShape(Circle())
                                        .environment(\.colorScheme, .light)
                                        .padding(10)
                                        .background(Color("DimGray"))
                                        .clipShape(Circle())
                                }
                                .offset(y: -30)
                            } else {
                                VStack {
                                    Image(systemName: tab.imageName())
                                    Text(activeTab == tab ? tab.name() : "")
                                        .font(.footnote)
                                }
                                .font(.title)
                                .padding(10)
                                .background(activeTab == tab ? Color("OffWhite").opacity(0.2) : .clear)
                                .clipShape(Circle())
                                .foregroundStyle(Color("OffWhite"))
                                .environment(\.colorScheme, .light)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .onTapGesture {
                                    activeTab = tab
                                }
                            }
                        }
                    }
                    .background(
                        Color("DimGray")
                    )
                }
            }
        }
        .padding(.bottom, 20)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color("OffWhite"))
        .onChange(of: selectedItem) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        selectedItem = nil
                        showSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            if croppedImage != nil {
                showCarDetail = true
            }
        }) {
            NavigationStack {
                CropImageView(image: $selectedImage) { image in
                    showSheet = false
                    croppedImage = image
                }
            }
        }
        .sheet(isPresented: $showCarDetail) {
            NavigationStack {
                CarAIView(vm: CarViewModel(uiImage: croppedImage!))
            }
        }
        .onAppear {
            Task {
                user.isListening = true
                await user.getHistory()
                user.isListening = false
            }
        }
        .onChange(of: croppedImage) {
            showCarDetail = true
        }
    }
	
	func save(image: UIImage) {
		selectedImage = image
	}
	
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
