//
//  FoodsterView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import SwiftUI

struct FoodsterSearchView: View {
    // Backend Requests
    @Binding var vm: FoodsterViewModel
    @Binding var location: String
    @Binding var term: String
    @Binding var sortBy: String
    @EnvironmentObject var locationManager: LocationManager
    @Binding var user: User
    @State private var sortTerm: String = "Best Match"
    var sortTerms: [String] = ["Best Match", "Review Count", "Distance", "Rating"]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search for restaurants", text: $term)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task {
                            await search()
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled((location.isEmpty && user.latitude == nil && user.longitude == nil) || vm.isLoading)
                    
                    Button {
                        locationManager.checkLocationAuthorization()
                        if let coordinate = locationManager.lastKnownLocation {
                            user.latitude = String(coordinate.latitude)
                            user.longitude = String(coordinate.longitude)
                        }
                        Task {
                            await search()
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "mappin")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding([.leading], 10)
                .padding([.trailing], 10)
            
                HStack {
                    TextField("Enter Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                        .task {
                            Task {
                                await search()
                            }
                        }
                    
                    Text("Sort By:")
                    Picker("Sort By:", selection: $sortTerm) {
                        ForEach(sortTerms, id: \.self) { term in
                            Text(term)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: sortTerm) {
                        switch sortTerm {
                        case "Best Match":
                            sortBy = "best_match"
                        case "Distance":
                            sortBy = "distance"
                        case "Review Count":
                            sortBy = "review_count"
                        case "Rating":
                            sortBy = "rating"
                        default:
                            break
                        }
                        Task {
                            if !location.isEmpty && !term.isEmpty {
                                await search()
                            }
                        }
                    }
                }
                .padding()
//                if let error = vm.errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                }
                
                List(vm.restaurants) { restaurant in
                    HStack {
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant)
                        } label: {
                            HStack {
                                RestaurantRow(restaurant: restaurant)
                            }
                        }
                        
                        Button {
                            Task {
                                await vm.saveRestaurant(restaurant: restaurant)
                            }
                        } label: {
                            Image(systemName: vm.savedRestaurants.contains(where: { $0.id == restaurant.id }) ? "bookmark.fill" : "bookmark")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    if !location.isEmpty {
                        await search()
                    }
                }
            }
            
            .navigationTitle("Foodster")
            .task {
                if !location.isEmpty {
                    await search()
                }
            }
            .overlay {
                if vm.restaurants.isEmpty {
                    ContentUnavailableView("No restaurants nearby.", systemImage: "fork.knife.circle", description: Text("Please enter another location above."))
                }
            }
        }
    }
    
    private func search() async {
        print("🔄 Triggering search...")
        print("🧭 Current location: \(user.latitude ?? "nil"), \(user.longitude ?? "nil")")
            
        await vm.getRestaurants(location: location, term: term, sortBy: sortBy, latitude: user.latitude, longitude: user.longitude)
        
        print("🔎 Search completed")
        print("🏢 Restaurants count: \(vm.restaurants.count)")
        dump(vm.restaurants) // Detailed object dump
    }
}

#Preview {
    @Previewable @State var vm = FoodsterViewModel()
    @Previewable @State var location = ""
    @Previewable @State var term = ""
    @Previewable @State var sortBy = "best_match"
    @Previewable @StateObject var locationManager = LocationManager()
    @Previewable @State var user = User()
    FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy, user: $user)
        .environmentObject(locationManager)
}
