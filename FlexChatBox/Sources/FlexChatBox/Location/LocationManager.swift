//
//  LocationManager.swift
//
//
//  Created by Aditya Kumar Bodapati on 03/03/23.
//

import CoreLocation

public struct Location: Identifiable {
    public let id = UUID()
    let coordinates: CLLocationCoordinate2D
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

    @Published var coordinates: CLLocationCoordinate2D?
    @Published var showSettingsAlert = false
    @Published var getCoordinates = false
    @Published var locationStatus: Bool?

    private override init() {
        super.init()
    }
    static let shared = LocationManager()

    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()

    func requestLocationUpdates() {
        (getCoordinates, showSettingsAlert) = (false, false)
        switch manager.authorizationStatus {
        case .notDetermined:
            locationStatus = nil
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            (getCoordinates, locationStatus) = (true, true)
            manager.startUpdatingLocation()
        case .denied:
            (locationStatus, showSettingsAlert) = (false, true)
        default:
            locationStatus = nil
        }
    }
    
    func checkLocationStatusWhenAppear() {
        switch manager.authorizationStatus {
        case .denied:
            locationStatus = false
        default:
            locationStatus = nil
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            (locationStatus, getCoordinates) = (true, true)
            manager.startUpdatingLocation()
        case .denied:
            locationStatus = false
        default:
            locationStatus = nil
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.coordinates = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
