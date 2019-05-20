//
//  Annotaition.swift
//  TheList
//
//  Created by Ofir Elias on 17/01/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//

import Foundation
import MapKit

enum AnnotaitionType {
    case cheap
    case tips
}

class Annotaition: NSObject,MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var annotationType: AnnotaitionType?
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}
