//
//  FoodsterDetailView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI


struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = restaurant.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.title)
                    
                    HStack {
                        Text(String(format: "%.1f", restaurant.rating))
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("(\(restaurant.reviewCount) reviews)")
                    }
                    
                    if let price = restaurant.price {
                        Text(price)
                    }
                    
                    Divider()
                    
                    Text("Address")
                        .font(.headline)
                    Text(restaurant.location.displayAddress.joined(separator: "\n"))
                    
                    Divider()
                    
                    Text("Contact")
                        .font(.headline)
                    Text(restaurant.displayPhone)
                    
                    if let url = URL(string: restaurant.url) {
                        Link("View on Yelp", destination: url)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

