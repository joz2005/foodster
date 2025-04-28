//
//  RestaurantScrollView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/14/25.
//

import SwiftUI

struct RestaurantScrollView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                ProgressView()
                            }
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                            .frame(height: 200)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .id("\(restaurant.id)-scroll-image")
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.subheadline)
                }
            }
            .frame(width: 350, alignment: .leading)
        }
        .frame(width: 350)
    }
}
