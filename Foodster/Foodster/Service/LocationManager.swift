//
//  LocationManager.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/15/25.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationPermissionGranted = false
    @Published var locationUpdated = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            authorizationStatus = locationManager.authorizationStatus
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            authorizationStatus = locationManager.authorizationStatus
            locationPermissionGranted = true
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationPermissionGranted = true
        case .denied, .restricted:
            locationPermissionGranted = false
        case .notDetermined:
            locationPermissionGranted = false
        @unknown default:
            locationPermissionGranted = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
            
        lastKnownLocation = location.coordinate
        locationUpdated = true
        locationManager.stopUpdatingLocation()
    }
}
