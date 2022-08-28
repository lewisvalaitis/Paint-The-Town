//
//  GameViewModel.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 08/08/2022.
//


import Combine
import MapKit
import SwiftUI

// MARK: - Game View Model
extension GameView {
    class ViewModel: ObservableObject {
        
        var mapUserData = UserMapData()
        private var locationManager =  LocationTracker(meterAccuracy: 5, minimumTrackDistance: 10)
        private var cancellables = Set<AnyCancellable>()
        
        @Published var userPath: [CLLocationCoordinate2D] = []
        @Published var currentLocation = CLLocationCoordinate2D()
        
        init() {
            locationManager.newLocation
                .receive(on: RunLoop.main)
                .sink { [weak self] location in                    
                    self?.mapUserData.currentLocation = location
                    
                    self?.mapUserData.userPath.append(location)
                }
                .store(in: &cancellables)
            
            locationManager.startUpdatingLocation()
        }
    }
}



