//
//  FoodsterViewModelProtocol.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation

protocol FoodsterViewModelProtocol: AnyObject {
    var service: FoodsterServiceProtocol { get }
    var restaurants: [Restaurant] { get set }
    var savedRestaurants: [Restaurant] { get set }
    var errorMessage: String? { get set }
    
    func getRestaurants(location: String) async
    func getRestaurant(id: String) async
}
