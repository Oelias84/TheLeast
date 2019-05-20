//
//  CustomerItem.swift
//  TheList
//
//  Created by Ofir Elias on 30/12/2018.
//  Copyright © 2018 Ofir Elias. All rights reserved.
//

import Foundation
import MapKit


class CustomerItem: Decodable{
    

    var id = ""
    var city = ""
    var streetName = ""
    var doorNumber = ""
    var houseNumber = ""
    var cheapped = 0
    var tipped = 0
    var customerIsCheap = false

    //check if the costumer is cheap
    func isCheap() {
        if cheapped >= 3{
            customerIsCheap = true
        }else {
            customerIsCheap = false
        }
    }
    
    
    static func == (lhs: CustomerItem, rhs: CustomerItem) -> Bool {
        return lhs.city == rhs.city && lhs.streetName == rhs.streetName && lhs.houseNumber == rhs.houseNumber
    }
}
