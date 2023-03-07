//
//  LocationManager.swift
//
//
//  Created by Aditya Kumar Bodapati on 03/03/23.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

    @Published var coordinates: CLLocationCoordinate2D?
    @Published var showSettingsAlert = false
    @Published var getCoordinates = false

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
        getCoordinates = false
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            getCoordinates = true
            manager.startUpdatingLocation()
        case .denied:
            showSettingsAlert = true
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            getCoordinates = true
            manager.startUpdatingLocation()
        case .denied:
            showSettingsAlert = true
        default:
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
