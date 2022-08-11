//
//  LocationTracker.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 09/08/2022.
//

import MapKit
import Combine
import CoreLocation


// MARK: - Location Tracker
public final class LocationTracker: NSObject {
    private let locationManager = CLLocationManager()
    private var coordinates: [CLLocationCoordinate2D] = [] {
        didSet {
            guard let last = coordinates.last else { return }
            newLocation.send(last)
        }
    }
    private let minimumTrackDistance: Double
    
    public let newLocation = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    // MARK: Initialiser
    init(meterAccuracy: Double, minimumTrackDistance: Double) {
        locationManager.desiredAccuracy = meterAccuracy
        self.minimumTrackDistance = minimumTrackDistance

        super.init()
        locationManager.delegate = self
    }
    
    func resetCoordinates() {
        if let last = coordinates.popLast() {
            coordinates = [last]
        } else {
            coordinates = []
        }
    }
}

// MARK: Methods
extension LocationTracker {
    public func startUpdatingLocation() {
        self.locationManager.requestAlwaysAuthorization()
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy <= manager.desiredAccuracy else {
            return
        }
        
        guard !coordinates.isEmpty else {
            coordinates.append(newLocation.coordinate)
            return
        }
        
        
        guard let previousLocation = coordinates.last,
              newLocation.coordinate.distance(to: previousLocation) != 0,
              newLocation.coordinate.distance(to: previousLocation) >= minimumTrackDistance else {
            return
        }
        
        coordinates.append(newLocation.coordinate)
    }
}

