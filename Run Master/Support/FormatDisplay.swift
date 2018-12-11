//
//  FormatDisplay.swift
//  Run Master
//
//  Created by Danny Espina on 11/23/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import Foundation
struct FormatDisplay {
    var averagePace: Double = 0
    
    static func distance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return FormatDisplay.distance(distanceMeasurement)
    }

    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        formatter.numberFormatter = numberFormatter
        return formatter.string(from: distance)
    }

    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }

    static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        formatter.numberFormatter = numberFormatter
        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
}

