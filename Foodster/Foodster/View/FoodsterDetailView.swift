//
//  FoodsterDetailView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import MapKit
import SwiftUI
import UIKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    let locationManager: LocationManager

    @State private var showCopyAlert = false
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Header
                imageHeaderSection
                
                // Info Cards
                HStack(spacing: 16) {
                    InfoCard(icon: "star.fill", title: String(format: "%.1f", restaurant.rating), subtitle: "Rating")
                    InfoCard(icon: "dollarsign.circle", title: restaurant.price ?? "—", subtitle: "Price")
                    InfoCard(icon: "phone.fill", title: restaurant.displayPhone, subtitle: "Contact")
                }
                .padding(.horizontal)
                
                // Address Section
                addressSection
                
                // Yelp Link
                yelpLinkSection
                
                // Map Section
                mapSection
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private var imageHeaderSection: some View {
        Group {
            if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                            case .empty:
                                Color.gray.opacity(0.2)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Color.red.opacity(0.2)
                            @unknown default:
                                Color.gray.opacity(0.2)
                        }
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    
                    Text(restaurant.name)
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding([.leading, .bottom], 16)
                }
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
            } else {
                Text(restaurant.name)
                    .font(.largeTitle).bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
            }
        }
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Address")
            
            HStack {
                Text(restaurant.location.displayAddress.joined(separator: ", "))
                    .font(.subheadline)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .onTapGesture {
                UIPasteboard.general.string = restaurant.location.displayAddress.joined(separator: ", ")
                showCopyAlert = true
            }
            .alert("Copied!", isPresented: $showCopyAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Address copied to clipboard")
            }

            .padding(.horizontal)
        }
    }
    
    private var yelpLinkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "More Info")
            
            Link(destination: URL(string: restaurant.url)!) {
                HStack {
                    Image(systemName: "link")
                    Text("View on Yelp")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .foregroundColor(.accentColor)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal)
        }
    }
    
    private var mapSection: some View {
        let coordinates = CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude)
        return VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Location")
            
            Map(position: $camera) {
                Marker(restaurant.name, systemImage: "fork.knife.circle.fill", coordinate: coordinates)

                                    if locationManager.locationPermissionGranted {
                                        Marker("You", systemImage: "person.fill", coordinate: locationManager.lastKnownLocation ?? coordinates)
                                    }
            }
            .frame(height: 300)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
            Spacer()
        }
        .padding(.horizontal)
    }
}

private struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    @Previewable @State var vm = FoodsterViewModel()
    @Previewable @State var location = "chapel hill"
    @Previewable @State var term = ""
    @Previewable @State var sortBy = "best_match"
    @Previewable @StateObject var locationManager = LocationManager()
    @Previewable @State var user = User()
    @Previewable @State var hasPerformedInitialFetch = false
    FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy, user: $user, hasPerformedInitialFetch: $hasPerformedInitialFetch)
        .environmentObject(locationManager)
}
