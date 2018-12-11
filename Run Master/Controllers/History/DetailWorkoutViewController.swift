//
//  DetailWorkoutViewController.swift
//  Run Master
//
//  Created by Danny Espina on 11/28/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}
class DetailWorkoutViewController: UIViewController, MGLMapViewDelegate, UIScrollViewDelegate {

    //var workout: Workouts!
    var polylineSource: MGLShapeSource?
    var mapView: MGLMapView!
    private var timer: Timer?
    private var currentIndex = 1
    private var saveMapViewFrame: CGRect!
    private var saveMapViewY: CGFloat!
    private var pointsArray: [CLLocationCoordinate2D]!
    @IBOutlet var mapContainer: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapHeight: NSLayoutConstraint!
    @IBOutlet var scrollViewTop: NSLayoutConstraint!
    @IBOutlet var expandMapButton: UIButton!
    @IBOutlet var closeMapButton: UIButton!
    @IBAction func expandMap(_ sender: UIButton) {
        scrollViewTop.constant = view.frame.size.height
        mapHeight.constant = view.frame.size.height
        sender.alpha = 0
        closeMapButton.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            self.mapView.frame = self.view.bounds
        }, completion:nil )
    }
    @IBAction func closeMap(_ sender: UIButton) {
        expandMapButton.alpha = 1
        
        scrollViewTop.constant = 0
        mapHeight.constant = saveMapViewFrame.height
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            
            self.mapView.layer.position.y = self.saveMapViewY
            
        }, completion: { _ in
            self.mapView.frame = self.saveMapViewFrame
            sender.alpha = 0
        } )
    }
//    @IBAction func delete( _sender: UIButton) {
//        
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeMapButton.alpha = 0
        
        self.mapView = MGLMapView(frame: mapContainer.bounds, styleURL: MGLStyle.darkStyleURL)
        self.saveMapViewFrame = mapView.frame
        self.saveMapViewY = mapView.layer.position.y

        //let mapViewStore = workout.mapViewStore as! MapViewStore
//        pointsArray = mapViewStore.pointsArray
//        let coordNE = mapViewStore.coordNE
//        let coordSW = mapViewStore.coordSW
        //let coordinateBound = MGLCoordinateBoundsMake(coordSW!, coordNE!)
        
        let edgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        
       // mapView.setVisibleCoordinateBounds(coordinateBound, edgePadding: edgeInsets, animated: true)

        mapContainer.addSubview(mapView)
        self.mapView.delegate = self
        self.scrollView.delegate = self
  
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        addLayer(to: style)

    }
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        animatePolyline()
    }
    func addLayer(to style: MGLStyle) {
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: UIColor.red)
        
        // The line width should gradually increase based on the zoom level.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 5, 18: 20])


        style.addLayer(layer)
        
    }
    func animatePolyline() {
        currentIndex = 1
        
        // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    @objc func tick() {
       
        if currentIndex > pointsArray.count {
            timer?.invalidate()
            timer = nil
            return
        }
         let coordinates = Array(pointsArray[0..<currentIndex])
        // Update our MGLShapeSource with the current locations.
        updatePolylineWithCoordinates(coordinates: coordinates)
        
        currentIndex += 1
      
    }
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        
        polylineSource?.shape = polyline

        
    }
   func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let swMapPoint = MKMapPoint.init(x: x, y: y)
        return swMapPoint.coordinate
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0
        {
            mapHeight.constant = 235 - offsetY
            mapView.frame = mapContainer.bounds
        }
        else
        {
            mapHeight.constant = 235
            mapView.frame = mapContainer.bounds
        }
        self.view.layoutIfNeeded()
    }
}
