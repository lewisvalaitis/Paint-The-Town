//
//  MapView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 08/08/2022.
//

import MapKit
import SwiftUI
import Combine


//  MARK: MapView
struct MapView: UIViewControllerRepresentable {
    
    @ObservedObject var data: UserMapData
    @Binding var trackUser: Bool

    public func makeUIViewController(context: Context) -> MapViewController {
        let mapVC = MapViewController()
        mapVC.configure(with: data)
        mapVC.delegate = self
        
        return mapVC
    }
    

    public func updateUIViewController(_ map: MapViewController, context: Context) {
        if trackUser != data.isTracking {
            data.isTracking = trackUser
        }
        map.update(with: data)
    }
}

extension MapView: MapViewControllerDelegate {
    func didMoveRegion() {
        trackUser = false
        data.isTracking = false
    }
}

