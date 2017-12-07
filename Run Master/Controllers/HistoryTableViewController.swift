//
//  HistoryViewController.swift
//  Run Master
//
//  Created by Danny Espina on 10/27/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import HealthKit
import CoreData
import CoreLocation
import Mapbox
import MapKit

class HistoryTableViewController: UITableViewController, MGLMapViewDelegate {
    
    private var workoutHealthArray: [HKWorkout]!
    private var polylineSource: MGLShapeSource?
    private let locationManager = LocationManager.shared
    var managedContext: NSManagedObjectContext!
   
    private var workouts: [Workouts] = []
    private var totalDistance: Double = 0
    private var totalCalories: Double = 0
    private lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(rgb: 0xf55116)

        let workoutFetch: NSFetchRequest<Workouts> = Workouts.fetchRequest()
        workoutFetch.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        do {
            let results = try managedContext.fetch(workoutFetch)
            workouts = results
            for workout in workouts {
                totalDistance = totalDistance + workout.distance
                totalCalories = totalCalories + workout.calories
            }
            totalDistance = totalDistance/1609.34
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        totalDistance = 0
        totalCalories = 0
    }
    // MARK: - UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 1) {
            return 293
        }
        return 100
    }
    
    // MARK: - UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1) {
            return workouts.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.section == 0) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalTableViewCell
            cell.totalMilesLabel.text = String(format: "%0.2f", totalDistance)
            cell.totalCalLabel.text = String(format: "%0.2f", totalCalories)
            
            return cell
        } else {
            // Get a cell to display the workout in.
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
            
            // Get the workout corresponding to this row.
            let workout = workouts[indexPath.row]
            
            // Get values from workout
            let calories = workout.calories
            let distance = Measurement(value: workout.distance, unit: UnitLength.meters)
            let duration = workout.duration
            
            // Set labels for date, distance, and pace
            if let date = workout.startDate {
                cell.dateLabel.text = dateFormatter.string(from: date)
            }
            if let snapshotData = workout.mapSnapshot {
                cell.mapSnapshotView.image = UIImage(data: snapshotData)
            }
            cell.distanceLabel.text = FormatDisplay.distance(distance)
            cell.caloriesLabel.text = String(format: "%0.2f cal", calories)
            cell.durationLabel.text = FormatDisplay.time(Int(duration))
            return cell
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailWorkout"?:
            if let row = tableView.indexPathForSelectedRow?.row {
                let workout = workouts[row]
                let detailWorkoutViewController = segue.destination as! DetailWorkoutViewController
                detailWorkoutViewController.workout = workout
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}

