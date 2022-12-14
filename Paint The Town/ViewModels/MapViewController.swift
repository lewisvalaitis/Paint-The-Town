//
//  MapViewModel.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 09/08/2022.
//

import MapKit
import SwiftUI
import Combine

protocol MapViewControllerDelegate {
    func didMoveRegion()
}

class MapViewController: UIViewController {
    private weak var userMapData: UserMapData?
    
    private let map = MKMapView()
    private var paintPinAnnotationView: MKAnnotationView?
    private var lastPaintPath: [CLLocationCoordinate2D] = []
    private var paintWidth: CGFloat {
        let defaultRegionLattitude = 0.0015365
        if let currentRegionLat = currentRegionLattitudeSpan {
            return 40 * (defaultRegionLattitude / currentRegionLat)
        } else {
            return 40
        }
    }
    private var currentRegionLattitudeSpan: Double?
    private var cancellables = Set<AnyCancellable>()
    
    public var delegate: MapViewControllerDelegate?
    
    class CustomPointAnnotation: MKPointAnnotation {
        func update(location: CLLocationCoordinate2D) {
            self.coordinate = location
        }
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
        
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self

        // add the gesture to the mapView
        map.addGestureRecognizer(panGesture)
    }
    
    public func update(with data: UserMapData) {
        draw()
        
        if data.isTracking {
            setUserRegion()
        }
    }
    
    public func configure(with data: UserMapData) {
        self.userMapData = data
    }
}

// MARK: - Private Methods
extension MapViewController {
    private func updateAnotationRollerPin(_ location: CLLocationCoordinate2D) {
        if paintPinAnnotationView != nil {
            
            setRollerImage(for: &paintPinAnnotationView!)
            
            (paintPinAnnotationView!.annotation as! CustomPointAnnotation).update(location: location)
        } else {
            let pointAnnotation = CustomPointAnnotation()
            
            pointAnnotation.coordinate = location
            
            paintPinAnnotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            
            map.addAnnotation(paintPinAnnotationView!.annotation!)
        }
    }
    
    private func draw() {
        func addOverlay(for path: [CLLocationCoordinate2D]) {
            let polyLine = MKPolyline(coordinates: path, count: path.count)
            map.addOverlay(polyLine)
            
            map.removeOverlays(map.overlays.filter { !($0 === polyLine) })
            
            // only updates the annotation view if the location has changed
            if path.last! != paintPinAnnotationView?.annotation?.coordinate {
                updateAnotationRollerPin(path.last!)
            }
        }
        
        guard let data = userMapData,
              data.userPath != lastPaintPath,
              let lastPoint = lastPaintPath.last,
              let newPoint = userMapData?.userPath.last else {
            
            if let newPath = userMapData?.userPath,
               !newPath.isEmpty {
                lastPaintPath = newPath
                addOverlay(for: newPath)
            }
                
            return
        }
        
        let latitudeDelta = newPoint.latitude - lastPoint.latitude
        let longitudeDelta = newPoint.longitude - lastPoint.longitude
        
        var deltas: [(Double, Double)] = []
        
        let amountOfIncrements = 15
        
        for i in 1...amountOfIncrements {
            let newLat = (latitudeDelta/Double(amountOfIncrements) * Double(i)) + lastPoint.latitude
            let newLong = (longitudeDelta/Double(amountOfIncrements) * Double(i)) + lastPoint.longitude
            deltas.append((newLat, newLong))
        }
        
        lastPaintPath.append(lastPoint)
        
        let timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
        
        deltas.publisher.zip(timer)
            .sink(receiveCompletion: { _ in
                self.lastPaintPath = data.userPath
            }, receiveValue: { newDelta, _ in
                let lastIndex = self.lastPaintPath.count - 1
                var animatePoint = self.lastPaintPath[lastIndex]
                animatePoint.latitude = newDelta.0
                animatePoint.longitude = newDelta.1
                self.lastPaintPath[lastIndex] = animatePoint
                addOverlay(for: self.lastPaintPath)
            })
            .store(in: &cancellables)
    }
    
    
    private func setRollerImage(for annotationView: inout MKAnnotationView){
        var image = UIImage(named: "PaintBrush") ?? UIImage()
        
        let rotationAngle: Float
        
        let pathCount = lastPaintPath.count
        
        if pathCount > 1 {
            rotationAngle = CLLocationCoordinate2D.angle(lastPaintPath[pathCount - 2],
                                                         lastPaintPath[pathCount - 1])
        } else {
            rotationAngle = 0
        }
        

        image = image.rotate(radians: rotationAngle) ?? UIImage()
        
        for annotation in self.map.annotations {
            if let customAnnotation = annotation as? CustomPointAnnotation {
                let annotationView = map.view(for: customAnnotation)
                annotationView?.image = image
                annotationView?.frame.size = CGSize(width: paintWidth * 1.2, height: paintWidth * 1.2, angle: CGFloat(rotationAngle))
            }
        }
    }
    
    private func setUserRegion() {
        guard let currentLocation = userMapData?.currentLocation else { return }
        
        let region = MKCoordinateRegion( center: currentLocation, latitudinalMeters: CLLocationDistance(exactly:100)!, longitudinalMeters: CLLocationDistance(exactly: 100)!)
        map.setRegion(map.regionThatFits(region), animated: true)
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        // User moved region
        delegate?.didMoveRegion()
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
        } else {
            annotationView?.annotation = annotation
        }
        
        setRollerImage(for: &annotationView!)

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if currentRegionLattitudeSpan == nil {
            currentRegionLattitudeSpan = mapView.region.span.latitudeDelta
            draw()
        } else if let regionLatSpan = currentRegionLattitudeSpan,
                  abs(mapView.region.span.latitudeDelta - regionLatSpan) > 0.0001 || currentRegionLattitudeSpan == nil {
            // user changed zoom
            currentRegionLattitudeSpan = mapView.region.span.latitudeDelta
            draw()
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
    // Allows over gestures to occur
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

extension CGSize {
    init(width: CGFloat, height: CGFloat, angle: CGFloat) {
        let newWidth = abs(width * sin(angle)) + abs(height * cos(angle))
        let newHeight = abs(width * cos(angle)) + abs(height * sin(angle))
        
        self.init(width: newWidth, height: newHeight)
    }
}
