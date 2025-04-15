//
//  FoodsterServiceProtocol.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation

protocol FoodsterServiceProtocol: AnyObject {
    func getRestaurants(location: String, term: String, sortBy: String, attribute: String, limit: Int) async throws -> [Restaurant]
    func getRestaurant(id: String) async throws -> Restaurant
}
