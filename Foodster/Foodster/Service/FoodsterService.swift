//
//  FoodsterService.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//

import Foundation

class FoodsterService: FoodsterServiceProtocol {
    private let apiKey: String = "vy7UHTeiuFcvIDLDulXCXknqM2i-1Xk6Mu_LG0Ix-Ox-zVcDDQPBJtq-i7GfyIqSrMXAEGXHGF1fCwXFHWyIZtSLHeMYOTLN-UK25m0qyotUUliuwZQbXp8tuk_1Z3Yx"
    
    func getRestaurants(location: String, term: String, sortBy: String, attribute: String, limit: Int = 50) async throws -> [Restaurant] {
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "term", value: "restaurant \(term)"),
            URLQueryItem(name: "radius", value: "16093"),
            URLQueryItem(name: "sort_by", value: sortBy),
            URLQueryItem(name: "limit", value: limit.formatted()),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "authorization": "Bearer \(apiKey)"
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(YelpResponse.self, from: data)
        return response.businesses
    }
    
    func getRestaurant(id: String) async throws -> Restaurant {
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)") else {
            throw URLError(.badURL)
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "authorization": "Bearer \(apiKey)"
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Received JSON: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(Restaurant.self, from: data)
        return response
        
    }
}
