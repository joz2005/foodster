//
//  YelpResponse.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import Foundation

struct YelpResponse: Codable {
    let businesses: [Restaurant]
    let total: Int?
    let region: Region?
}
