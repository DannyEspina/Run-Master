//
//  MapAndStatsViewController.swift
//  Run Master
//
//  Created by Danny Espina on 11/14/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import CoreData
import CoreLocation
import MapboxStatic

class StatsViewController: UIViewController {

    var workout: RunMasterWorkout!
    var duration: Int!
    var distance: Double!
    var calories: Double!
    var averagePace: Double!
    // MARK: - Connected labels & UIView
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var avgPaceLabel: UILabel!
    //@IBOutlet var resultMapContainer: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets all instance variables from workout object.
        calories = workout.calories
        duration = workout.duration
        distance = workout.distance
        averagePace = workout.averagePace
        
        // Set label texts.
        durationLabel.text = FormatDisplay.time(duration)
        caloriesLabel.text = String(format: "%0.1f cal", workout.calories)
        distanceLabel.text = FormatDisplay.distance(distance)
        avgPaceLabel.text = String(format: "%0.2f min/mi", averagePace)
        
    }
}
