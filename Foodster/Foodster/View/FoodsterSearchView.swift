//
//  FoodsterView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import SwiftUI

struct FoodsterSearchView: View {
    // Backend Requests
    @Environment(\.modelContext) private var modelContext
    @Binding var vm: FoodsterViewModel
    @Binding var location: String
    @Binding var term: String
    @Binding var sortBy: String
    @EnvironmentObject var locationManager: LocationManager
    @Binding var user: User
    @Binding var hasPerformedInitialFetch: Bool
    @State private var showErrorAlert = false
    @State private var sortTerm: String = "Best Match"
    var sortTerms: [String] = ["Best Match", "Review Count", "Distance", "Rating"]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search for restaurants", text: $term)
                        .textFieldStyle(.roundedBorder)
                            .padding(8)
                            .cornerRadius(8)
                            .colorScheme(.light)
                            .onSubmit {
                                Task {
                                    await loadData()
                                }
                            }
                    
                    Button {
                        Task {
                            await loadData()
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
                            location = ""
                            await loadData()
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
                        .colorScheme(.light)
                        .onSubmit {
                            user.latitude = nil
                            user.longitude = nil
                            Task { await loadData() }
                        }
                    
                    Text("Sort By:")
                    Picker("Sort By:", selection: $sortTerm) {
                        ForEach(sortTerms, id: \.self) { term in
                            Text(term)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: sortTerm) { _, newValue in
                        switch newValue {
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
                        
                        if !location.isEmpty || (user.latitude != nil && user.longitude != nil) {
                            Task {
                                await loadData()
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
                
                List(vm.restaurants, id: \.id) { restaurant in
                    HStack {
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant, locationManager: locationManager)
                        } label: {
                            HStack {
                                RestaurantRow(restaurant: restaurant)
                                
                                Spacer()
                                
                                Button {
                                    vm.toggleSaveRestaurant(restaurant: restaurant, in: modelContext)
                                } label: {
                                    Image(systemName: vm.savedRestaurants.contains(where: { $0.id == restaurant.id }) ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 24))
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .refreshable {
                    if !location.isEmpty {
                        await loadData()
                    }
                }
            }
            .navigationTitle("Foodster")
            .onAppear {
                if !hasPerformedInitialFetch {
                    locationManager.checkLocationAuthorization()
                }
                vm.refreshSavedRestaurants(in: modelContext)
            }
            .onChange(of: locationManager.locationPermissionGranted) { _, granted in
                if granted && !hasPerformedInitialFetch {
                    if let coordinate = locationManager.lastKnownLocation {
                        user.latitude = String(coordinate.latitude)
                        user.longitude = String(coordinate.longitude)
                        Task {
                            await loadData()
                            hasPerformedInitialFetch = true
                        }
                    }
                }
            }
            .onChange(of: locationManager.locationUpdated) { _, updated in
                if updated && !hasPerformedInitialFetch {
                    if let coordinate = locationManager.lastKnownLocation {
                        user.latitude = String(coordinate.latitude)
                        user.longitude = String(coordinate.longitude)
                        Task {
                            await loadData()
                            hasPerformedInitialFetch = true
                        }
                    }
                }
            }
            .onChange(of: modelContext) {
                vm.refreshSavedRestaurants(in: modelContext)
            }
            .overlay {
                if vm.restaurants.isEmpty {
                    ContentUnavailableView("No restaurants nearby.", systemImage: "fork.knife.circle", description: Text("Please enter another location above."))
                }
            }
        }
    }
    
    private func loadData() async {
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
    @Previewable @State var hasPerformedInitialFetch = false
    FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy, user: $user, hasPerformedInitialFetch: $hasPerformedInitialFetch)
        .environmentObject(locationManager)
}
