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
                            Text("Search")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoading)
                    .disabled(location.isEmpty)
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
                            Image(systemName: vm.savedRestaurants.contains(where: {$0.id == restaurant.id}) ? "bookmark.fill" : "bookmark")
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
                    ContentUnavailableView ("No restaurants nearby.", systemImage: "fork.knife.circle", description: Text("Please enter another location above."))
                }
            }
        }
    }
    
    private func search() async {
        await vm.getRestaurants(location: location, term: term, sortBy: sortBy)
    }
}


#Preview {
    @Previewable @State var vm: FoodsterViewModel = FoodsterViewModel()
    @Previewable @State var location: String = "Chapel Hill"
    @Previewable @State var term: String = "Chinese"
    @Previewable @State var sortBy: String = "best_match"
    FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy)
}
