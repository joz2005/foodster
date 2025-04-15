//
//  FoodsterHomeView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI

struct FoodsterHomeView: View {
    @Binding var vm: FoodsterViewModel
    @Binding var location: String
    @Binding var user: User
    @EnvironmentObject var locationManager: LocationManager
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
            .task {
                await loadData()
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
                .submitLabel(.search)
                .onSubmit {
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
                            RestaurantDetailView(restaurant: restaurant)
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
                ForEach(vm.restaurants) { restaurant in
                    NavigationLink {
                        RestaurantDetailView(restaurant: restaurant)
                    } label: {
                        HStack {
                            RestaurantRow(restaurant: restaurant)
                            
                            Spacer()
                            
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
                    .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No restaurants found",
            systemImage: "fork.knife",
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
    FoodsterHomeView(vm: $vm, location: $location, user: $user)
        .environmentObject(locationManager)
}
