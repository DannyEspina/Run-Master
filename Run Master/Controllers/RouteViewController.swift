//
//  AchievementViewController.swift
//  Run Master
//
//  Created by Danny Espina on 10/27/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox

class RouteViewController: UIViewController {
    
    var mapView: MGLMapView!
    var locationManager = LocationManager.shared
    
    @IBOutlet var routeMapContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MGLMapView(frame: routeMapContainer.bounds, styleURL: MGLStyle.darkStyleURL())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Centered at user location
        mapView.setCenter((locationManager.location?.coordinate)!, zoomLevel: 13, animated: true)
        routeMapContainer.addSubview(mapView)
        
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(rgb: 0xfc2836)
        
    }


}
