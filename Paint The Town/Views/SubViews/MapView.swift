//
//  MapView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 08/08/2022.
//

import MapKit
import SwiftUI


//  MARK: MapView
struct MapView: UIViewControllerRepresentable {
    @ObservedObject private var data: UserMapData
    
    init(userMapData: UserMapData) {
        data = userMapData
    }

    public func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }

    public func updateUIViewController(_ map: MapViewController, context: Context) {
        map.configure(with: data)
    }
}

