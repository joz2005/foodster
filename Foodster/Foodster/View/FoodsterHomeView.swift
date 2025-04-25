//
//  FoodsterHomeView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI
import SwiftData

struct FoodsterHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var vm: FoodsterViewModel
    @Binding var location: String
    @Binding var user: User
    @EnvironmentObject var locationManager: LocationManager
    @Binding var hasPerformedInitialFetch: Bool
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchSection
                    
                    if vm.isLoading {
                        loadingSection
                    } else {
                        contentSection
                    }
                }
                .padding()
            }
            .navigationTitle("Foodster")
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "Unknown error occurred")
            }
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
            .refreshable {
                await loadData()
            }
        }
    }
    
    private var searchSection: some View {
        HStack {
            TextField("Enter location", text: $location)
                .textFieldStyle(.roundedBorder)
                .colorScheme(.light)
                .submitLabel(.search)
                .onSubmit {
                    user.latitude = nil
                    user.longitude = nil
                    Task { await loadData() }
                }
            
            Button(action: { Task { await loadData() } }) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "magnifyingglass")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading || location.isEmpty)
            
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
    }
    
    private var loadingSection: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0 ..< 3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 180)
                    }
                }
                .padding(.horizontal)
            }
            
            ProgressView()
                .padding(.vertical, 30)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            if !vm.popularRestaurants.isEmpty {
                popularRestaurantsSection
                    .padding(.bottom, 8)
            }
                    
            if !vm.restaurants.isEmpty {
                allRestaurantsSection
                    .padding(.top, 8)
            } else if !vm.isLoading {
                emptyStateView
            }
        }
        .padding(.vertical, 8)
    }
    
    private var popularRestaurantsSection: some View {
        VStack(alignment: .leading) {
            Text("Popular Nearby")
                .font(.title2.bold())
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(vm.popularRestaurants) { restaurant in
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant, locationManager: locationManager)
                        } label: {
                            RestaurantScrollView(restaurant: restaurant)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 350)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var allRestaurantsSection: some View {
        VStack(alignment: .leading) {
            Text("All Restaurants")
                .font(.title2.bold())
                .padding(.horizontal)
            
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.restaurants, id: \.id) { restaurant in
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
            .padding(.horizontal, 8)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No restaurants found.",
            systemImage: "fork.knife.circle",
            description: Text("Try searching in a different location")
        )
    }
    
    private func loadData() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await vm.getRestaurants(location: location, term: "", sortBy: "best_match", latitude: user.latitude, longitude: user.longitude)
                }
                group.addTask {
                    await vm.getPopularRestaurants(location: location, latitude: user.latitude, longitude: user.longitude)
                }
                try await group.waitForAll()
            }
        } catch {
            showErrorAlert = true
        }
    }
}

#Preview {
    @Previewable @State var vm = FoodsterViewModel()
    @Previewable @State var location = ""
    @Previewable @State var user = User()
    @Previewable @StateObject var locationManager = LocationManager()
    @Previewable @State var hasPerformedInitialFetch = false
    FoodsterHomeView(vm: $vm, location: $location, user: $user, hasPerformedInitialFetch: $hasPerformedInitialFetch)
        .environmentObject(locationManager)
}
