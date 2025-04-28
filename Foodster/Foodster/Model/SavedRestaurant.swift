//
//  SavedRestaurant.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/19/25.
//

import Foundation
import SwiftData

@Model
final class SavedRestaurant {
    var id: String
    var name: String
    var imageUrl: String?
    var isClosed: Bool
    var url: String
    var reviewCount: Int
    var rating: Double
    var price: String?
    var phone: String
    var displayPhone: String
    var distance: Double
    
    // Coordinates
    var latitude: Double
    var longitude: Double
    
    // Location
    var address: [String]
    var city: String
    var zipCode: String
    var country: String
    var state: String
    
    // Categories
    var categories: [String]
    
    // Timestamp when saved
    var savedAt: Date
    
    init(
        id: String,
        name: String,
        imageUrl: String?,
        isClosed: Bool,
        url: String,
        reviewCount: Int,
        rating: Double,
        price: String?,
        phone: String,
        displayPhone: String,
        distance: Double,
        latitude: Double,
        longitude: Double,
        address: [String],
        city: String,
        zipCode: String,
        country: String,
        state: String,
        categories: [String],
        savedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.isClosed = isClosed
        self.url = url
        self.reviewCount = reviewCount
        self.rating = rating
        self.price = price
        self.phone = phone
        self.displayPhone = displayPhone
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.country = country
        self.state = state
        self.categories = categories
        self.savedAt = savedAt
    }
    
    convenience init(from restaurant: Restaurant) {
        self.init(
            id: restaurant.id,
            name: restaurant.name,
            imageUrl: restaurant.imageUrl,
            isClosed: restaurant.isClosed,
            url: restaurant.url,
            reviewCount: restaurant.reviewCount,
            rating: restaurant.rating,
            price: restaurant.price,
            phone: restaurant.phone,
            displayPhone: restaurant.displayPhone,
            distance: restaurant.distance,
            latitude: restaurant.coordinates.latitude,
            longitude: restaurant.coordinates.longitude,
            address: restaurant.location.displayAddress,
            city: restaurant.location.city,
            zipCode: restaurant.location.zipCode,
            country: restaurant.location.country,
            state: restaurant.location.state,
            categories: restaurant.categories.map { $0.title }
        )
    }
    
    // Convert back to Restaurant
    func toRestaurant() -> Restaurant {
        let coordinate = Coordinate(latitude: latitude, longitude: longitude)
        let location = Location(
            address1: address.first ?? "",
            address2: address.count > 1 ? address[1] : nil,
            address3: address.count > 2 ? address[2] : nil,
            city: city,
            zipCode: zipCode,
            country: country,
            state: state,
            displayAddress: address
        )
        let categories = self.categories.map { Category(alias: $0.lowercased().replacingOccurrences(of: " ", with: "_"), title: $0) }
        
        return Restaurant(
            id: id,
            alias: name.lowercased().replacingOccurrences(of: " ", with: "-"),
            name: name,
            imageUrl: imageUrl,
            isClosed: isClosed,
            url: url,
            reviewCount: reviewCount,
            categories: categories,
            rating: rating,
            coordinates: coordinate,
            transactions: nil,
            price: price,
            location: location,
            phone: phone,
            displayPhone: displayPhone,
            distance: distance,
            businessHours: nil,
            attributes: nil
        )
    }
}
