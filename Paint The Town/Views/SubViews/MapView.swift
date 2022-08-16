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
struct MapView: UIViewControllerRepresentable, Animatable {
    
    @ObservedObject var data: UserMapData

    public func makeUIViewController(context: Context) -> MapViewController {
        let mapVC = MapViewController()
        mapVC.configure(with: data)
        
        return mapVC
    }

    public func updateUIViewController(_ map: MapViewController, context: Context) {
        map.update(with: data)
    }
}

