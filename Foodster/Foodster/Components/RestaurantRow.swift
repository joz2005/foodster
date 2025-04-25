//
//  RestaurantRow.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftData
import SwiftUI

struct RestaurantRow: View {
    let restaurant: Restaurant
    private var restaurantId: String { "\(restaurant.id)-\(restaurant.imageUrl ?? "")" }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                    @unknown default:
                        EmptyView()
                            .frame(width: 60, height: 60)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .id("\(restaurantId)-row-image")
                
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurant.location.displayAddress.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(String(format: "%.1f", restaurant.rating))
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("(\(restaurant.reviewCount))")
                }
                .font(.caption)
            }
        }
        .id(restaurantId)
    }
}
