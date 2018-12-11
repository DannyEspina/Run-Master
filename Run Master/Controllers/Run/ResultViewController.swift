//
//  ResultViewController.swift
//  Run Master
//
//  Created by Danny Espina on 10/24/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import Mapbox
import MapKit
import CoreData
import CoreLocation
import MapboxStatic

class ResultViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Instance variables
    var workout: RunMasterWorkout!
    //var managedContext: NSManagedObjectContext!
    var coordNE: CLLocationCoordinate2D!
    var coordSW: CLLocationCoordinate2D!
 
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var mapView: UIImageView!
    @IBOutlet var placePicLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    @IBOutlet var imageWidth: NSLayoutConstraint!

    // MARK: - Connected Action calls
    // Saves workout to healthkit and places it on History tableViewController
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        // Saves workout to healthkit
        WorkoutDataStore.save(RunMasterWorkout: workout) { (success, error) in
            
            // If succcessful in saving workout dismiss both viewControllers. Else display alert.
            if success {
                print("save to Apple Health")
            } else {
                print("Didn't save to Apple Health")
            }
        }
        
        
        //let workoutStore = Workouts(context: managedContext)
        
//        workoutStore.averagePace = workout.averagePace
//        workoutStore.calories = workout.calories
//        workoutStore.desc = workout.discription
//        workoutStore.distance = workout.distance
//        workoutStore.duration = Int32(workout.duration)
//        workoutStore.elevationGain = workout.elevationGain
//        workoutStore.elevationLoss = workout.elevationLoss
//        workoutStore.startDate = workout.startDate
//        workoutStore.endDate = workout.endDate
//        workoutStore.imageData = workout.imageData
//        workoutStore.mapSnapshot = workout.snapshotData
        
//        let mapViewStore = MapViewStore(coordNE: coordNE, coordSW: coordSW, pointsArray: workout.pointsArray)
//        workoutStore.mapViewStore = mapViewStore
//        
//        do {
//
//            try managedContext.save()
//        } catch let error {
//            print("Couldn't save \(error)")
//        }
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    // Closes out resultViewController and MapViewController without saving
    @IBAction func discard(_ sender: UIBarButtonItem) {
        let title = "Discard this workout?"
        let message = "Are you sure you want to discard this workout?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) -> Void in
           
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
        ac.addAction(discardAction)
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func deletePic(_ sender: UIButton) {
        let title = "Delete image?"
        let message = "Are you sure you want to delete this image?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            self.imageView.image = nil
            self.placePicLabel.isEnabled = true
            self.placePicLabel.alpha = 1
            self.imageView.layer.borderColor = UIColor.white.cgColor
            sender.isEnabled = false
        })
        ac.addAction(delete)
        present(ac, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = SnapshotOptions( styleURL: MGLStyle.darkStyleURL, size: CGSize(width: 375, height: 192))
        let polylines = Path(coordinates: workout.pointsArray)
        polylines.fillColor = UIColor.clear
        polylines.strokeColor = UIColor.red
        polylines.strokeWidth = 3
        options.overlays = [polylines]
        
        let snapshot = Snapshot(
            options: options,
            accessToken: "pk.eyJ1IjoiZGFubnllc3BpbmEiLCJhIjoiY2o5N2I3c2QxMDVlMDMybjNtOHF6Mm1vNSJ9.w9gnowvCgENBhyipUKJwew"
        )

        snapshot.image { (image, error) in
            self.mapView.image = image
            self.workout.snapshotData = image!.pngData()
        }
        
        let pointsArray = workout.pointsArray
        
        // creates rectangles from two points and unites them together. loop through each point collected.
        var flyTo = MKMapRect.null
        // set this in mapViewController for better preformance
        for coordinate in pointsArray! {
            // convert CLCoordinate to MKMapPoint
            let point = MKMapPoint.init (coordinate)
            
            let pointRect = MKMapRect.init(x: point.x, y: point.y, width: 0, height: 0)
            if flyTo.isNull {
                flyTo = pointRect
            } else {
                flyTo = flyTo.union(pointRect)
            }
        }
        
        // Creates bounds.
        coordNE = getCoordinateFromMapRectanglePoint(x: flyTo.origin.x, y: flyTo.maxY)
        coordSW = getCoordinateFromMapRectanglePoint(x: flyTo.maxX, y: flyTo.origin.y)
        
        self.deleteButton.isEnabled = false
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        toolbar.barTintColor = UIColor.white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
          let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        self.descriptionTextView.inputAccessoryView = toolbar
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        self.imageView.isUserInteractionEnabled = true
        
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.descriptionTextView.text = "How was your run?"
        self.descriptionTextView.textColor = UIColor.lightGray
        
        self.descriptionTextView.delegate = self
        
     
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "containerSegue"?:
            let pageController = segue.destination as! ResultPageViewController

            pageController.workout = workout

        default:
            preconditionFailure("Unexpected segue identifer.")
        }
    }
    // Creates a CllocationCoordinates2D from mapRect
    func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D {
        let swMapPoint = MKMapPoint.init(x: x, y: y)
        return swMapPoint.coordinate
    }
    @objc func imageTapped()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            })
            let photoLibrary = UIAlertAction(title: "Photo Library", style: .default , handler: { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            ac.addAction(camera)
            ac.addAction(photoLibrary)
            ac.addAction(cancel)
            present(ac, animated: true, completion: nil)
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // Get picked image from info dictionary
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        // Put that image on the screen in the image view
        imageView.image = image
        workout.imageData = image.pngData()
        imageView.backgroundColor = UIColor(rgb: 0x1B1E25)
        
        if image.size.width > image.size.height {
            imageHeight.constant = 260
            imageWidth.constant = 340
        }
        else if image.size.width < image.size.height {
            imageHeight.constant = 340
            imageWidth.constant = 260
        }
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        placePicLabel.isEnabled = false
        placePicLabel.alpha = 0
        
        deleteButton.isEnabled = true
       
        dismiss(animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "How was your run?"
            textView.textColor = UIColor.lightGray
            workout.discription = ""
        } else {
            workout.discription = textView.text
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
