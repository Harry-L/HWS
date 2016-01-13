//
//  Capital.swift
//  Project19
//
//  Created by Harry Liu on 2016-01-13.
//  Copyright © 2016 HarryLiu. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate 
        self.info = info
    }
    
}
