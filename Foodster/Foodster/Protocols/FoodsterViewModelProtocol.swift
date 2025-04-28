//
//  FoodsterViewModelProtocol.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation
import SwiftData

protocol FoodsterViewModelProtocol: AnyObject {
    var service: FoodsterServiceProtocol { get }
    var restaurants: [Restaurant] { get set }
//    var unfilteredRestaurants: [Restaurant] { get set }
    var savedRestaurants: [Restaurant] { get set }
    var errorMessage: String? { get set }

    func getRestaurants(location: String, term: String, sortBy: String, latitude: String?, longitude: String?) async
    func getRestaurant(id: String) async
//    func getUnfilteredRestaurants(location: String, latitude: String?, longitude: String?) async
    func getPopularRestaurants(location: String, latitude: String?, longitude: String?) async
    func isRestaurantSaved(_ restaurant: Restaurant, in context: ModelContext) -> Bool
    func toggleSaveRestaurant(restaurant: Restaurant, in context: ModelContext)
}
