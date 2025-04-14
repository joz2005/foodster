//
//  RestaurantRow.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI

struct RestaurantRow: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.location.displayAddress.joined(separator: "\n"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(String(format: "%.1f", restaurant.rating))
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("(\(restaurant.reviewCount))")
                }
                .font(.caption)
            }
        }
    }
}
