//
//  MiscFields.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation

struct Region: Codable {
    let center: Coordinate
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct Category: Codable {
    let alias: String
    let title: String
}

struct BusinessHours: Codable {
    let open: [OpenHours]
    let hoursType: String
    let isOpenNow: Bool
    
    enum CodingKeys: String, CodingKey {
        case open
        case hoursType = "hours_type"
        case isOpenNow = "is_open_now"
    }
}

struct OpenHours: Codable {
    let isOvernight: Bool
    let start: String
    let end: String
    let day: Int
    
    enum CodingKeys: String, CodingKey {
        case isOvernight = "is_overnight"
        case start, end, day
    }
}

struct Attributes: Codable {
    let businessTempClosed: Bool?
    let menuUrl: String?
    let open24Hours: Bool?
    let waitlistReservation: Bool?
    
    enum CodingKeys: String, CodingKey {
        case businessTempClosed = "business_temp_closed"
        case menuUrl = "menu_url"
        case open24Hours = "open24_hours"
        case waitlistReservation = "waitlist_reservation"
    }
}
