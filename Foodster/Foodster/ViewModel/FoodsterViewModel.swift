//
//  FoodsterViewModel.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//
import Foundation
import SwiftData

@Observable
class FoodsterViewModel: ObservableObject {
    var restaurants: [Restaurant] = []
//    var unfilteredRestaurants: [Restaurant] = []
    var popularRestaurants: [Restaurant] = []
    var restaurant: Restaurant? = nil
    var errorMessage: String? = nil
    var isLoading: Bool = false
    
    var savedRestaurants: [SavedRestaurant] = []
    
    func refreshSavedRestaurants(in context: ModelContext) {
        let descriptor = FetchDescriptor<SavedRestaurant>()
        savedRestaurants = (try? context.fetch(descriptor)) ?? []
    }
    
    func getRestaurants(location: String, term: String, sortBy: String, latitude: String? = nil, longitude: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRestaurants = try await service.getRestaurants(
                location: location,
                term: term,
                sortBy: sortBy,
                attribute: "",
                limit: 50,
                latitude: latitude,
                longitude: longitude
            )

            restaurants = fetchedRestaurants
            if fetchedRestaurants.isEmpty {
                errorMessage = "No restaurants found in this area"
            }
        } catch {
            restaurants = []
            errorMessage = "Search failed: \(error.localizedDescription)"
            print("API Error: \(error)")
        }
        
        isLoading = false
    }
    
    func getRestaurant(id: String) async {
        isLoading = true
        errorMessage = nil
        restaurant = nil
        
        do {
            let fetchedRestaurant = try await service.getRestaurant(id: id)

            restaurant = fetchedRestaurant
            
        } catch {
            errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
        }
    }
    
    func isRestaurantSaved(_ restaurant: Restaurant, in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<SavedRestaurant>(
            predicate: #Predicate { $0.id == restaurant.id }
        )
        
        do {
            let savedRestaurants = try context.fetch(descriptor)
            return !savedRestaurants.isEmpty
        } catch {
            print("Error checking if restaurant is saved: \(error)")
            return false
        }
    }
    
    func toggleSaveRestaurant(restaurant: Restaurant, in context: ModelContext) {
        let descriptor = FetchDescriptor<SavedRestaurant>(
            predicate: #Predicate { $0.id == restaurant.id }
        )
        
        do {
            let savedRestaurants = try context.fetch(descriptor)
            
            if let existingSaved = savedRestaurants.first {
                context.delete(existingSaved)
            } else {
                let savedRestaurant = SavedRestaurant(from: restaurant)
                context.insert(savedRestaurant)
            }
            refreshSavedRestaurants(in: context)
        } catch {
            print("Error toggling restaurant save status: \(error)")
        }
    }

    func getPopularRestaurants(location: String, latitude: String?, longitude: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRestaurants = try await service.getRestaurants(location: location, term: "", sortBy: "best_match", attribute: "hot_and_new", limit: 8, latitude: latitude, longitude: longitude)
  
            popularRestaurants = fetchedRestaurants
            
        } catch {
            errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    let service: FoodsterService
    
    required init(service: FoodsterService = FoodsterService()) {
        self.service = service
    }
}
