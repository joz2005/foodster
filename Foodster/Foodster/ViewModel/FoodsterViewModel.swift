//
//  FoodsterViewModel.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//
import Foundation

func makeFoodsterViewModel(service: FoodsterServiceProtocol) -> FoodsterViewModelProtocol? {
    return FoodsterViewModel(service: service)
}

@Observable
class FoodsterViewModel: FoodsterViewModelProtocol {
    
    var savedRestaurants: [Restaurant] = []
    var restaurants: [Restaurant] = []
    var popularRestaurants: [Restaurant] = []
    var restaurant: Restaurant? = nil
    var errorMessage: String? = nil
    var isLoading: Bool = false
    
    func getRestaurants(location: String, term: String, sortBy: String) async {
        isLoading = true
        errorMessage = nil
            
        do {
            let fetchedRestaurants = try await service.getRestaurants(location: location, term: term, sortBy: sortBy, attribute: "", limit: 50)
            await MainActor.run {
                restaurants = fetchedRestaurants
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
            }
        }
            
        await MainActor.run {
            isLoading = false
        }
    }
    
    func getRestaurant(id: String) async {
        isLoading = true
        errorMessage = nil
        restaurant = nil
        
        do {
            let fetchedRestaurant = try await service.getRestaurant(id: id)
            await MainActor.run {
                restaurant = fetchedRestaurant
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
            }
        }
    }
    
    func saveRestaurant(restaurant: Restaurant) async {
        isLoading = false
        errorMessage = nil
        
        do {
            if savedRestaurants.contains(where: { $0.id == restaurant.id }) {
                savedRestaurants.removeAll(where: { $0.id == restaurant.id })
            } else {
                savedRestaurants.append(restaurant)
            }
        } catch {
            errorMessage = "Failed to save/unsave restaurant: \(error.localizedDescription)"
        }
    }
    
    func getPopularRestaurants(location: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRestaurants = try await service.getRestaurants(location: location, term: "", sortBy: "best_match", attribute: "hot_and_new", limit: 8)
            await MainActor.run {
                popularRestaurants = fetchedRestaurants
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    let service: FoodsterServiceProtocol
    
    required init(service: FoodsterServiceProtocol = FoodsterService()) {
        self.service = service
    }
}
