//
//  ViewController.swift
//  TheList
//
//  Created by Ofir Elias on 16/12/2018.
//  Copyright © 2018 Ofir Elias. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import SwiftKeychainWrapper



class LoginViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var notRegisteredButton: UIButton!
    @IBOutlet var LoginViewController: UIView!
    
    @IBOutlet weak var errorUserNameLable: UILabel!
    @IBOutlet weak var errorPasswordLable: UILabel!
    let isStartAnimation: Bool? = KeychainWrapper.standard.bool(forKey: "isStartAnimation")
    let retrievedUserName: String? = KeychainWrapper.standard.string(forKey: "userName")
    let retrievedUserPassword: String? = KeychainWrapper.standard.string(forKey: "password")
    
    let URL = "https://frozen-meadow-31076.herokuapp.com/api/users/"
    let alertService = AlertService()
    
    var animationView = AnimationView()
    var myView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isStartAnimation != false{
            startAnimation()
        }else{
            checkIfLoged()
        }
        
        setUp()
        
    }
    
    func setUp() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
    
        notRegisteredButton.setTitle("Don't have an account?", for: .focused)
        
        //login button design
        uiButtonChane(button: loginButton)
        
        //text fields design
        uiThextFieldChange(ui: userNameTextField)
        uiThextFieldChange(ui: passwordTextField)
        tapGesture()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        loginAnimation()
        login()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.loginButton.isHidden = false
    }
    
    ///////MARK:Animations Funcs
    func loginAnimation() {
        animationView = AnimationView(name: "loadingAnimation")
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height:  150)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        myView.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        myView.frame = self.view.frame
        animationView.animationSpeed = 1.5
        animationView.loopMode = .loop
        view.addSubview(myView)
        view.addSubview(animationView)
        self.animationView.play()
    }
    
    func startAnimation(){
        let animation = AnimationView(name: "pinAnimation")
        let startView = UIView()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        
        label.text = "LEAST THEM ALL"
        label.font = UIFont(name: "helvetica", size: 20)
        label.textAlignment = NSTextAlignment.center
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y + 150
        startView.addSubview(label)
        startView.backgroundColor = UIColor.white
        startView.frame = self.view.frame
        
        animation.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animation.center = self.view.center
        animation.contentMode = .scaleAspectFill
        animation.animationSpeed = 1.2
        view.addSubview(startView)
        view.addSubview(animation)
        
        animation.play { (Bool) in
            startView.removeFromSuperview()
            animation.removeFromSuperview()
        }
        
    }
    
    func stopAnimation(){
        self.animationView.stop()
        self.animationView.isHidden = true
        self.myView.isHidden = true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            if (textField.text?.count)! > 4 && textField.text?.count != 0{
                textField.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
                self.errorUserNameLable.isHidden = true
            }else{
                self.errorUserNameLable.isHidden = false
                self.errorUserNameLable.text = "Must enter a currect User Name"
            }
        }else if textField == passwordTextField{
            if (textField.text?.count)! > 4 && textField.text?.count != 0{
                textField.resignFirstResponder()
                self.errorPasswordLable.isHidden = true
                loginAnimation()
                login()
            }else{
                self.errorPasswordLable.isHidden = false
                self.errorPasswordLable.text = "Password must contain 5 charecters"
            }
        }
        return true
    }
    
    func tapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        LoginViewController.addGestureRecognizer(tapGesture)
    }
    
    @objc func tableViewTapped(){
        userNameTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    
    //MARK: Text filed ui design
    func uiThextFieldChange(ui: UITextField) {
        ui.layer.borderWidth = 1.5
        ui.layer.borderColor = UIColor.blue.cgColor
        ui.layer.cornerRadius = 10
    }
    
    //MARK: button ui design
    func uiButtonChane(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.blue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.5
    }
    
    //Check if User is logged
    func checkIfLoged(){
        var name = String()
        var password = String()
        
        if let loggedUserName = retrievedUserName{
            name = loggedUserName
        }
        if let loggedUserPassword = retrievedUserPassword{
            password = loggedUserPassword
        }
        let user: Parameters = [
            "name": name,
            "password": password
        ]
        self.loginAnimation()
        Alamofire.request(URL + "loginCheck", method: .post, parameters: user, encoding: JSONEncoding.default).responseString { (respone) in
            if respone.result.isSuccess{
                if respone.response?.statusCode == 200{
                    self.stopAnimation()
                    self.performSegue(withIdentifier: "loginToMap", sender: self)
                }else if respone.response?.statusCode == 300{
                    self.stopAnimation()
                    print("hi")
                }
            }else{
                self.stopAnimation()
                print("walla")
                print(respone.response?.statusCode as Any)
            }
        }
    }
    
    
    //User login
    func login() {
        let user: Parameters = [
            "name": self.userNameTextField.text!,
            "password": self.passwordTextField.text!
        ]
        
        Alamofire.request(URL + "login", method: .put, parameters: user, encoding: JSONEncoding.default).responseString {
            respone in
            if respone.result.isSuccess{
                print(respone.result.value!)
                self.animationView.stop()
                self.animationView.isHidden = true
                self.myView.isHidden = true
                switch respone.response?.statusCode {
                case 200:
                    self.stopAnimation()
                    let _: Bool = KeychainWrapper.standard.set(self.userNameTextField.text!, forKey: "userName")
                    let _: Bool = KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: "password")
                    let _: Bool = KeychainWrapper.standard.set(false, forKey: "isStartAnimation")
                    self.performSegue(withIdentifier: "loginToMap", sender: self)
                case 400:
                    self.stopAnimation()
                    self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: respone.result.value!, buttonTitle: "Ok", isGood: false, needButton: true), animated: true)
                default:
                    self.stopAnimation()
                    self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: "Somthing whent wrong please try again", buttonTitle: "Ok", isGood: false, needButton: true), animated: true)
                }
            }else{
                self.stopAnimation()
                self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: respone.result.value!, buttonTitle: "Try again", isGood: false, needButton: true), animated: true)
            }
        }
    }
}
