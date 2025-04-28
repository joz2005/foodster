//
//  Restaurant.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//

import Foundation

struct Restaurant: Codable, Identifiable {
    let id: String
    let alias: String
    let name: String
    let imageUrl: String?
    let isClosed: Bool
    let url: String
    let reviewCount: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Coordinate
    let transactions: [String]?
    let price: String?
    let location: Location
    let phone: String
    let displayPhone: String
    let distance: Double
    let businessHours: [BusinessHours]?
    let attributes: Attributes?
    
    enum CodingKeys: String, CodingKey {
        case id
        case alias
        case name
        case url
        case categories
        case coordinates
        case transactions
        case price
        case location
        case phone
        case distance
        case attributes
        case imageUrl = "image_url"
        case isClosed = "is_closed"
        case reviewCount = "review_count"
        case rating
        case displayPhone = "display_phone"
        case businessHours = "business_hours"
    }
}
