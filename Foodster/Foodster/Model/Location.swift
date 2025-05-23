//
//  Location.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation

struct Location: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String
    let zipCode: String
    let country: String
    let state: String
    let displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case address1
        case address2
        case address3
        case city
        case country
        case state
        case zipCode = "zip_code"
        case displayAddress = "display_address"
    }
}
