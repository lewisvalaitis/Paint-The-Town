//
//  CLLocation+distance.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 09/08/2022.
//

import CoreLocation
import MapKit

internal extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(other))
    }
}
