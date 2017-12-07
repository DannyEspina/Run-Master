//
//  MapViewController.swift
//  Run Master
//
//  Created by Danny Espina on 10/24/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import CoreData

class MapViewController: UIViewController{
    
    var managedContext: NSManagedObjectContext!
    var saveTabBarHeight: CGFloat!
    var saveTabBarY: CGFloat!
    // MARK: - Timer Varaibles
    private var seconds = 0
    private var timer: Timer?
    
    // MARK: - Elevation Variables
    var elevationGain: Double = 0
    var elevationLoss: Double = 0
    
    // MARK: - Map Variables
    var mapView: MGLMapView!
    let locationManager = LocationManager.shared
    var oldlocation: CLLocation!
    var polylineSource: MGLShapeSource?
    var pointsArray: [CLLocationCoordinate2D]! = []
   
    // MARK: - Distance, Pace and Average Pace Variables
    private var distance: Double = 0
    var averagePace: Double = 0
    var paceCount: Double = 0
    var calories: Double = 0
    // MARK: - Start and End Dates Variables
    var startDate: Date!
    var endDate: Date!
    var trackingMode: MGLUserTrackingMode!
    
    // MARK: - Connected Labels, Buttons & Views
    @IBOutlet var startButton: UIButton!
    @IBOutlet var endButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var chooseRunButton: UIButton!
    @IBOutlet var chooseRouteButton: UIButton!
    
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var mapContainer: UIView!
    @IBOutlet var statsContainer: UIView!
    @IBOutlet var buttonViewContainer: UIView!
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet var buttonViewBottom: NSLayoutConstraint!
    @IBOutlet var statViewBottom: NSLayoutConstraint!
    

    // MARK: - Connected Action Calls

    @IBAction func centerLocation(_ sender: UIButton) {
       
        if trackingMode == .none || trackingMode == .followWithHeading{
            trackingMode = .follow
            mapView.setUserTrackingMode(trackingMode, animated: false)
            sender.setImage(#imageLiteral(resourceName: "locationOn"), for: .normal)
        } else if trackingMode == .follow {
            trackingMode = .followWithHeading
            mapView.setUserTrackingMode(trackingMode, animated: false)
            sender.setImage(#imageLiteral(resourceName: "locationTrack"), for: .normal)
        }
    }
    // Start run.
    @IBAction func startRun(_ sender: UIButton) {
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Setting tab bar height when user presses start button
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabBar = self.tabBarController?.tabBar
        saveTabBarHeight = tabFrame?.size.height
        saveTabBarY = tabFrame?.origin.y
        print("this \(saveTabBarHeight) \(saveTabBarY)")
        tabFrame?.size.height = 0
        
        // The items in the tab bar will move when the height changes. so we move them back
        let tabBarItems = tabBar?.items

            for item in tabBarItems! {
                item.imageInsets.bottom = -46
                item.imageInsets.left = 70

            }
        
        // setting constraints
        buttonViewHeight.constant = 90
        buttonViewBottom.constant = -100
        statViewBottom.constant = 83
       
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.alpha = 0
            self.pauseButton.alpha = 1
            self.buttonViewContainer.backgroundColor = UIColor(rgb: 0x1e1f25)
            self.statsContainer.backgroundColor = UIColor(rgb: 0x1e1f25)
            self.backgroundView.backgroundColor = UIColor(rgb: 0x1e1f25)
            self.mapContainer.backgroundColor = UIColor(rgb: 0x1e1f25)
            self.view.layoutIfNeeded()
            
            tabFrame?.origin.y = self.view.frame.size.height + 100
            tabBar?.frame = tabFrame!
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.chooseRouteButton.alpha = 0
            self.chooseRunButton.alpha = 0
        })
            
        
        chooseRouteButton.isEnabled = false
        chooseRunButton.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        
        if trackingMode == .none {
            mapView.setUserTrackingMode(.follow, animated: true)
            locationButton.setImage(#imageLiteral(resourceName: "locationOn"), for: .normal)
        }
        mapView.setZoomLevel(16, animated: true)
        
        // Start Button disappears and disenabled.
        
        sender.isEnabled = false
        
        // Stops button and pause button appears and enabled.
        
        self.pauseButton.isEnabled = true
        // Saves start date.
        self.startDate = Date()
    }
    // End run.
    @IBAction func endRun(_ sender: UIButton) {
        
        locationManager.allowsBackgroundLocationUpdates = false
        
        // Stops timer.
        timer?.invalidate()
        // Stops updating user's location.
        self.locationManager.stopUpdatingLocation()
        
        // saves end date.
        self.endDate = Date()
        
        // If the user doesn't move from one location displays an alert. Prevents app from crashing when
        // going to resultViewController.
        guard pointsArray.count > 1 else {
            let title = "Something Went Wrong"
            let message = "You didn't ran far enough to give any meaningful results OR user location is not authorized"
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            resetView(true)
            resetValues()
            return
        }
    }
    
    @IBAction func pause(_ sender: UIButton) {
      
        timer?.invalidate()
        self.locationManager.stopUpdatingLocation()
        self.resumeButton.isEnabled = true
        self.endButton.isEnabled = true
        sender.isEnabled = false
        self.resumeButton.center.x += self.view.bounds.width/3
        self.endButton.center.x -= self.view.bounds.width/3
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0 , options: [.curveEaseIn], animations: {
            self.resumeButton.alpha = 1
            self.endButton.alpha = 1
            sender.alpha = 0
            
            self.resumeButton.center.x -= self.view.bounds.width/3
            self.endButton.center.x += self.view.bounds.width/3
        }, completion: nil)

    }
    @IBAction func resume(_ sender: UIButton) {
       // start()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        self.locationManager.startUpdatingLocation()
        self.pauseButton.isEnabled = true
        sender.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
            sender.alpha = 0
            self.endButton.alpha = 0
            self.pauseButton.alpha = 1
            self.resumeButton.center.x += self.view.bounds.width/3
            self.endButton.center.x -= self.view.bounds.width/3
        }, completion: { _ in
            self.resumeButton.center.x -= self.view.bounds.width/3
            self.endButton.center.x += self.view.bounds.width/3
        } )
        
    }
    
    // MARK: - ViewDidLoad & Prepare for Segue
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        locationButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        locationButton.layer.shadowOpacity = 1.0
        locationButton.layer.shadowRadius = 0.0
        locationButton.layer.masksToBounds = false
        locationButton.layer.cornerRadius = 4.0
        
        startButton.layer.shadowColor = UIColor(rgb: 0x125433).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0.0, height: 5)
        startButton.layer.shadowOpacity = 1.0
        startButton.layer.shadowRadius = 0.0
        startButton.layer.masksToBounds = false
        startButton.layer.cornerRadius = 4.0
        
        // Disenable the endButton and pauseButton and make it disappear.
        self.endButton.alpha = 0
        self.endButton.isEnabled = false
        self.pauseButton.alpha = 0
        self.pauseButton.isEnabled = false
        self.resumeButton.alpha = 0
        self.resumeButton.isEnabled = false
        // Sets the map to view the user's current location with a certain style.
        self.mapView = MGLMapView(frame: mapContainer.bounds, styleURL: MGLStyle.darkStyleURL())
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setUserTrackingMode(.follow, animated: true)
        trackingMode = .follow
         locationButton.setImage(#imageLiteral(resourceName: "locationOn"), for: .normal)
        // Center map at user location.
        if let coordinate = locationManager.location?.coordinate {
            self.mapView.setCenter(coordinate, zoomLevel: 14, animated: false)
        }
        // Adds mapView to the UIView container.
        self.mapContainer.addSubview(mapView)

        // Allow the app to display the user's location.
        self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 5
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        self.mapView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        resetValues()
        resetView(false)
    }
    func resetValues() {
        paceCount = 0
        seconds = 0
        distance = 0
        calories = 0
        averagePace = 0
        elevationGain = 0
        elevationLoss = 0
        pointsArray.removeAll()
        if let location = locationManager.location?.coordinate {
            updatePolylineWithCoordinates(coordinates: [location])
        }
        updateDisplay()
    }
    func resetView(_ animated: Bool) {
        
        self.endButton.alpha = 0
        self.endButton.isEnabled = false
        self.resumeButton.alpha = 0
        self.resumeButton.isEnabled = false
        self.startButton.alpha = 1
        self.startButton.isEnabled = true
        
        self.tabBarController?.tabBar.tintColor = UIColor(rgb: 0xFF4821)
      
        self.resumeButton.alpha = 0
        self.endButton.alpha = 0
        
        if saveTabBarY != nil && saveTabBarHeight != nil {
            var tabFrame = self.tabBarController?.tabBar.frame
            let tabBar = self.tabBarController?.tabBar
            tabFrame?.size.height = saveTabBarHeight
            
            let tabBarItems = tabBar?.items
            
            for item in tabBarItems! {
                item.imageInsets.bottom = -6
                item.imageInsets.left = 0
                
            }
            buttonViewHeight.constant = 158
            buttonViewBottom.constant = 0
            statViewBottom.constant = 0
            
            if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.buttonViewContainer.backgroundColor = UIColor(rgb: 0x242831)
                self.statsContainer.backgroundColor = UIColor(rgb: 0x242831)
                self.backgroundView.backgroundColor = UIColor(rgb: 0x242831)
                self.mapContainer.backgroundColor = UIColor(rgb: 0x242831)
                tabFrame?.origin.y = self.saveTabBarY
                tabBar?.frame = tabFrame!
            })
            UIView.animate(withDuration: 0.3, delay: 0.2, animations: {
                self.chooseRouteButton.isEnabled = true
                self.chooseRouteButton.alpha = 1
                self.chooseRunButton.isEnabled = true
                self.chooseRunButton.alpha = 1
            }, completion: nil)
            
            } else {
                self.view.layoutIfNeeded()
                self.buttonViewContainer.backgroundColor = UIColor(rgb: 0x242831)
                self.statsContainer.backgroundColor = UIColor(rgb: 0x242831)
                self.backgroundView.backgroundColor = UIColor(rgb: 0x242831)
                self.mapContainer.backgroundColor = UIColor(rgb: 0x242831)
                tabFrame?.origin.y = self.saveTabBarY
                tabBar?.frame = tabFrame!
                
                self.chooseRouteButton.isEnabled = true
                self.chooseRouteButton.alpha = 1
                self.chooseRunButton.isEnabled = true
                self.chooseRunButton.alpha = 1
            }
        }
    }
    // Prepares what's going to be sent to resultViewController to display the result of the run.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showResults"?:
        
            let resultViewController = segue.destination as! ResultViewController
    
            var totalEnergyBurned: Double {
        
                let RunMasterCaloriesPerHour: Double = 450
                let hours: Double = Double(seconds/3600)
                let totalCalories = RunMasterCaloriesPerHour*hours
        
                return totalCalories
            }

            if paceCount == 0 {
                averagePace = 0
            } else {
                averagePace = averagePace / paceCount
            }
       
            var workout = RunMasterWorkout()
            workout.startDate = startDate
            workout.endDate = endDate
            workout.distance = distance
            workout.duration = seconds
            workout.elevationGain = elevationGain
            workout.elevationLoss = elevationLoss
            workout.averagePace = averagePace
            workout.calories = totalEnergyBurned
            workout.mapView = mapView
            workout.pointsArray = pointsArray
        
            resultViewController.workout = workout
            resultViewController.managedContext = managedContext

        default:
            preconditionFailure("Unexpected segue identifer.")
        }
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Timer
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let measureDistance = Measurement(value: distance, unit: UnitLength.meters)
   
        let formattedDistance = FormatDisplay.distance(measureDistance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: measureDistance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        let speedMagnitude = seconds != 0 ? measureDistance.value / Double(seconds) : 0
        
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        let speedMinMil = speed.converted(to: UnitSpeed.minutesPerMile)
        averagePace += speedMinMil.value
        
        paceCount += measureDistance.value != 0 ? 1 : 0
        
        distanceLabel.text = formattedDistance
        durationLabel.text = formattedTime
        paceLabel.text = formattedPace
        
    }
}
// MARK: - UIColor
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
extension MapViewController: CLLocationManagerDelegate, MGLMapViewDelegate {
    // Stops when self.locationManager.stopUpdatingLocation() is called
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        if let coordinate = manager.location?.coordinate, let location = manager.location {
            
            let howRecent = location.timestamp.timeIntervalSinceNow
            guard location.horizontalAccuracy < 20 && abs(howRecent) < 10 else { return }
            // Add coordinates to an array for later calculations
            pointsArray.append(coordinate)
            
            // Only calcualte distance when there's more then one coordinate created.
            if pointsArray.count > 1 {
                
                // Calculates elevation gain and loss.
                let elevation = oldlocation.altitude - location.altitude
                
                if elevation > 0 {
                    elevationGain += elevation
                } else if elevation < 0 {
                    elevationLoss += fabs(elevation)
                }
                distance = distance + location.distance(from: oldlocation)
            }
            // Saves the current location for the next update.
           oldlocation = location
            // Always keep track of user on the map when running.
            
            updatePolylineWithCoordinates(coordinates: pointsArray)
        }
    }
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        addLayer(to: style)
    }
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        
        var mutableCoordinates = coordinates
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        
        // Updating the MGLShapeSource’s shape and redraw our map with polylines of the current coordinates.
        polylineSource?.shape = polyline
        
    }
    
    func addLayer(to style: MGLStyle) {
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        layer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        layer.lineColor = MGLStyleValue(rawValue: UIColor.red)
        layer.lineWidth = MGLStyleFunction(interpolationMode: .exponential, cameraStops: [14: MGLConstantStyleValue<NSNumber>(rawValue: 2.5), 18: MGLConstantStyleValue<NSNumber>(rawValue: 6)], options: [.defaultValue : MGLConstantStyleValue<NSNumber>(rawValue: 1)])
        style.addLayer(layer)
        
    }
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        if mode == .none {
            locationButton.setImage(#imageLiteral(resourceName: "locationOff"), for: .normal)
            trackingMode = .none
        }
        
    }
    
}
