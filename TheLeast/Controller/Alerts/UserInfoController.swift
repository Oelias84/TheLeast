//
//  UserInfoController.swift
//  TheLeast
//
//  Created by Ofir Elias on 19/05/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

protocol UserInfoDelegate: class {
    func logoutBtnTapped()
}

class UserInfoController: UIViewController {
    
    @IBOutlet weak var userNameLable: UILabel!
    @IBOutlet weak var userLogoutButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    var delegate: UserInfoDelegate?
    var name = String()
    var password = String()
    
    let retrievedUserName: String? = KeychainWrapper.standard.string(forKey: "userName")
    let retrievedUserPassword: String? = KeychainWrapper.standard.string(forKey: "password")
    
    let URL = "https://frozen-meadow-31076.herokuapp.com/api/users/logout"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        if let loggedUserName = retrievedUserName{
            self.userNameLable.text = loggedUserName
            name = loggedUserName
        }
        if let userPassword = retrievedUserPassword{
            password = userPassword
        }
        
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.shadowRadius = 10
        viewContainer.layer.shadowOpacity = 0.1
        viewContainer.layer.shadowRadius = 6
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        uiButton(button: userLogoutButton)
    }
    
    @IBAction func screanTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.logoutBtnTapped()
       
        //self.dismiss(animated: true, completion: nil)
        logoutUser()
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uiButton(button: UIButton){
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.blue.cgColor
    }
    
    
    
    func logoutUser(){
       
        let user: Parameters = [
            "name": name,
            "password": password
        ]
        
        Alamofire.request(URL, method: .put, parameters: user, encoding: JSONEncoding.default).responseString { (respone) in
            if respone.result.isSuccess{
                print(respone.result.value!)
                let _: Bool = KeychainWrapper.standard.set(true, forKey: "isStartAnimation")
            }
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
}
