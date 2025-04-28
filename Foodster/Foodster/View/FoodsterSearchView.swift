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
                    // Search TextField with icon
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Search for restaurants...", text: $term)
                            .padding(.vertical, 10)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await loadData() }
                            }
                        
                        if !term.isEmpty {
                            Button {
                                term = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Location Button
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
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                
                HStack(spacing: 12) {
                    TextField("Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit {
                            user.latitude = nil
                            user.longitude = nil
                            Task { await loadData() }
                        }
                    
                    Menu {
                        Picker("Sort By", selection: $sortTerm) {
                            ForEach(sortTerms, id: \.self) { term in
                                Label(term, systemImage: iconForSortTerm(term))
                            }
                        }
                    } label: {
                        HStack {
                            Text("Sort")
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
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
                }
                .padding(.horizontal)
//                if let error = vm.errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                }
                
                List(vm.restaurants, id: \.id) { restaurant in
                    HStack {
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant, locationManager: locationManager, vm: vm)
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
            .navigationTitle("Search")
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
    
    private func iconForSortTerm(_ term: String) -> String {
        switch term {
        case "Best Match": return "rosette"
        case "Distance": return "map"
        case "Review Count": return "text.bubble"
        case "Rating": return "star.fill"
        default: return "arrow.up.arrow.down"
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
