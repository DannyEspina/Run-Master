//
//  elevationStat.swift
//  Run Master
//
//  Created by Danny Espina on 11/16/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit

class ElevationChartViewController: UIViewController {
    var elevationGainValue: Double!
    var elevationLossValue: Double!
    @IBOutlet var elevationGain: UILabel!
    @IBOutlet var elevationLoss: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elevationGain.text = String(format: "%0.1f", elevationGainValue)
        elevationLoss.text = String(format: "%0.1f", elevationLossValue)
    }
}
