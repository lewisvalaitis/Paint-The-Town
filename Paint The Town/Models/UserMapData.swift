//
//  UserMapData.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 10/08/2022.
//

import Foundation
import CoreLocation

class UserMapData: ObservableObject {
    @Published var userPath: [CLLocationCoordinate2D] = []
    @Published var currentLocation: CLLocationCoordinate2D?
}
