

import UIKit
import Mapbox
import MapKit
import CoreLocation

class MapViewStore: NSObject, NSCoding {

    var coordNE: CLLocationCoordinate2D!
    var coordSW: CLLocationCoordinate2D!
    var coordNELat: Double!
    var coordNELon: Double!
    var coordSWLat: Double!
    var coordSWLon: Double!
    
    var pointsArray: [CLLocationCoordinate2D] = []
    var latArray: [Double] = []
    var lonArray: [Double] = []
    init(coordNE: CLLocationCoordinate2D, coordSW: CLLocationCoordinate2D, pointsArray: [CLLocationCoordinate2D]) {
        
        self.coordNE = coordNE
        self.coordSW = coordSW
        self.pointsArray = pointsArray
    }
    func encode(with aCoder: NSCoder) {
        
        coordNELat = coordNE.latitude
        coordNELon = coordNE.longitude
        coordSWLat = coordSW.latitude
        coordSWLon = coordSW.longitude
        
        aCoder.encode(coordNELat, forKey: "coordNELat")
        aCoder.encode(coordNELon, forKey: "coordNELon")
        aCoder.encode(coordSWLat, forKey: "coordSWLat")
        aCoder.encode(coordSWLon, forKey: "coordSWLon")
        
        for i in 0..<pointsArray.count {
            latArray.append(pointsArray[i].latitude)
            lonArray.append(pointsArray[i].longitude)
        }
        aCoder.encode(latArray, forKey: "latArray")
        aCoder.encode(lonArray, forKey: "lonArray")
    }
    required init(coder aDecoder: NSCoder) {
        
        self.coordNELat = aDecoder.decodeObject(forKey: "coordNELat") as! Double
        self.coordNELon = aDecoder.decodeObject(forKey: "coordNELon") as! Double
        self.coordSWLat = aDecoder.decodeObject(forKey: "coordSWLat") as! Double
        self.coordSWLon = aDecoder.decodeObject(forKey: "coordSWLon") as! Double
        
        self.coordNE = CLLocationCoordinate2D(latitude: coordNELat, longitude: coordNELon)
        self.coordSW = CLLocationCoordinate2D(latitude: coordSWLat, longitude: coordSWLon)
        
        self.latArray = aDecoder.decodeObject(forKey: "latArray") as! [Double]
        self.lonArray = aDecoder.decodeObject(forKey: "lonArray") as! [Double]
        
        for i in 0..<lonArray.count {
            let coordinate = CLLocationCoordinate2D(latitude: latArray[i], longitude: lonArray[i])
            pointsArray.append(coordinate)
        }
    }
    
   
    
}
