//
//  FoodsterService.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//

import Foundation

class FoodsterService {
    private let apiKey: String = "OMITTED"
    
    func getRestaurants(location: String, term: String, sortBy: String, attribute: String, limit: Int = 50, latitude: String? = "37.774722", longitude: String? = "-122.41823") async throws -> [Restaurant] {
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems: [URLQueryItem] = []
            
        if !location.isEmpty {
            queryItems.append(URLQueryItem(name: "location", value: location))
        } else {
            queryItems.append(URLQueryItem(name: "latitude", value: latitude))
            queryItems.append(URLQueryItem(name: "longitude", value: longitude))
        }

        queryItems += [
            URLQueryItem(name: "term", value: "restaurant \(term)"),
            URLQueryItem(name: "radius", value: "16093"),
            URLQueryItem(name: "sort_by", value: sortBy),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
            
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "authorization": "Bearer \(apiKey)",
        ]

        let (data, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(YelpResponse.self, from: data).businesses
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
            "authorization": "Bearer \(apiKey)",
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(Restaurant.self, from: data)
        return response
    }
}
