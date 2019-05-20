//
//  AlertService.swift
//  TheLeast
//
//  Created by Ofir Elias on 03/05/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//
import UIKit

import Foundation

class AlertService {
    
    
    func alert(mainTitle: String, descText: String, buttonTitle: String, isGood: Bool, needButton: Bool) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as!
        AlertViewController
        
        alertVC.isButton = needButton
        alertVC.theTitle = mainTitle
        alertVC.desc = descText
        alertVC.actionButtonText = buttonTitle
        alertVC.isGood = isGood
        
        return alertVC
    }
    
    
    func cheapOrTippAlert(mainTitle: String, descText: String, isTipped: Bool) -> CheapOrTippController {
        
        let storyboard = UIStoryboard(name: "CheapOrTippStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CheapOrTippVC") as! CheapOrTippController
        
        alertVC.isGood = isTipped
        alertVC.theTitle = mainTitle
        alertVC.desc = descText
        
        return alertVC
    }
    
    func UserInfoAlert() -> UserInfoController {
        
        let storyboard = UIStoryboard(name: "UserInfoStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "UserInfoStroryboard") as! UserInfoController
        
        return alertVC
    }
}
