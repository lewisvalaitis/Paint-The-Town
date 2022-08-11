//
//  MapViewModel.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 09/08/2022.
//

import MapKit


class MapViewController: UIViewController {
    
    private weak var userMapData: UserMapData?
    
    private let map = MKMapView()
    private var paintPinAnnotationView: MKPinAnnotationView!
    private let paintWidth = 20
    
    class CustomPointAnnotation: MKPointAnnotation {
        var pinCustomImageName:String!
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        view.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
    
    public func configure(with data: UserMapData) {
        self.userMapData = data
        
        map.addOverlay(MKPolyline(coordinates: data.userPath, count: data.userPath.count))
        
        if let currentLocation = data.currentLocation {
            let region = MKCoordinateRegion( center: currentLocation, latitudinalMeters: CLLocationDistance(exactly:100)!, longitudinalMeters: CLLocationDistance(exactly: 100)!)
            map.setRegion(map.regionThatFits(region), animated: true)
            
            setAnotationRollerPin()
        }
    }
}

// MARK: - Private Methods
extension MapViewController {
    private func setAnotationRollerPin() {
        guard let data = userMapData,
              data.userPath.count >= 1 else { return }
        
        map.removeAnnotations(map.annotations)
        
        let pointAnnotation = CustomPointAnnotation()
        pointAnnotation.pinCustomImageName = "PaintBrush"
        pointAnnotation.coordinate = data.userPath.last!
        
        paintPinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        map.addAnnotation(paintPinAnnotationView.annotation!)
    }
}


// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: line)
            renderer.strokeColor = .red
            renderer.lineWidth = CGFloat(paintWidth)
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        var rollerImage = (UIImage(named: customPointAnnotation.pinCustomImageName) ?? UIImage())
        
        
        rollerImage = rollerImage.rotate(radians: .pi / 2) ?? UIImage()
        
        annotationView?.image = rollerImage
        annotationView?.frame.size = CGSize(width: paintWidth, height: paintWidth)

        return annotationView
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
