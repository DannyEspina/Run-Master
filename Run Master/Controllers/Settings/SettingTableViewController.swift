//
//  SettingViewController.swift
//  Run Master
//
//  Created by Danny Espina on 10/27/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
import CoreLocation

class SettingTableViewController: UITableViewController {

    private let authorizeHealthKitSection = 2
    private let authorizeUserLocationSection = 3
    private let locationManager = CLLocationManager()
    
    private func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
        
        }
    }
    private func authorizeUserLocation () {
        let title = "Active User location"
        let message = "To active user location services go to: Settings > Privacy > Location Services > Run Master"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("why \(indexPath.section)")
        if indexPath.section == authorizeHealthKitSection {
            authorizeHealthKit()
        } else if indexPath.section == authorizeUserLocationSection {
            authorizeUserLocation()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(rgb: 0xE66108)
    }

}
