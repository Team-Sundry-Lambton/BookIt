//
//  PlaceObject.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-12.
//

import Foundation
import MapKit

class PlaceObject: NSObject {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
