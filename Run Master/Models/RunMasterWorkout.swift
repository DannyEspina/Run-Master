//
//  RunMasterWorkout.swift
//  Run Master
//
//  Created by Danny Espina on 11/22/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import CoreLocation

struct RunMasterWorkout {
    var startDate: Date!
    var endDate: Date!
    var distance: Double!
    var duration: Int!
    var elevationGain: Double!
    var elevationLoss: Double!
    var averagePace: Double!
    var calories: Double!
    var mapView: MGLMapView!
    var pointsArray: [CLLocationCoordinate2D]!
    var discription: String!
    var imageData: Data!
    var snapshotData: Data!
}
