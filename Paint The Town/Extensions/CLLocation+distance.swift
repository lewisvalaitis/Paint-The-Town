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
    
    /// Calculates the angle relative to North in Radians
    static func angle(_ coorOne: CLLocationCoordinate2D, _ coorTwo: CLLocationCoordinate2D) -> Float {
        let x = coorTwo.longitude - coorOne.longitude
        let y = coorTwo.latitude - coorOne.latitude
        
        return Float(atan2(x, y))
    }
}
