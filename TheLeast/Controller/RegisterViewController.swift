//
//  RegisterViewController.swift
//  TheList
//
//  Created by Ofir Elias on 06/02/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import Lottie


class RegisterViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var RegisterViewController: UIView!
    @IBOutlet weak var userNameErrorLable: UILabel!
    @IBOutlet weak var emailErrorLable: UILabel!
    @IBOutlet weak var passwordErrorLable: UILabel!
    @IBOutlet weak var createLable: UILabel!
    @IBOutlet weak var creatLableConstrain: NSLayoutConstraint!
    
    
    let backgroundImageView =  UIImageView()
    let alertService = AlertService()
    var animationView = AnimationView()
    var myView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI appearance
        uiButtonChane(button: registerButton)
        uiThextFieldChange(ui: emailTextField)
        uiThextFieldChange(ui: passwordTextField)
        uiThextFieldChange(ui: userNameTextField)
        
        tapGesture()
        
        setBackground()
        keyboardListenr()
    }
    
    func setBackground(){
        let size = self.view.frame.height
        
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.image = UIImage(named: "Background")
        view.sendSubviewToBack(backgroundImageView)
        
        
        if (size < 667.0 ){
            textSize(size: 35.0)
            creatLableConstrain.constant = 0
        }else{
            textSize(size: 40.0)
            creatLableConstrain.constant = 70
        }
        
    }
    
    
    func keyboardListenr(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanges(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanges(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanges(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @objc func keyboardChanges(notification: Notification) {
        let size = self.view.frame.height
        
        if (size < 667.0 ){
            self.view.frame.origin.y = -210
        }else{
            self.view.frame.origin.y = -220
        }
        
    }
    
    @IBAction func registerBurtton(_ sender: Any) {
        loginAnimation()
        userRgister()
    }
    
    func textSize(size: CGFloat){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        
        let attrString = NSMutableAttributedString(string: "Create\nYour\nAccount")
        
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        createLable.font = createLable.font.withSize(size)
        createLable.attributedText = attrString
    }
    
    
    //Assures The prompt information from the user
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            if (textField.text?.count)! > 4 && textField.text?.count != 0 {
                textField.resignFirstResponder()
                emailTextField.becomeFirstResponder()
                self.userNameErrorLable.isHidden = true
            }else{
                self.userNameErrorLable.isHidden = false
                self.userNameErrorLable.text = "Must enter a User Name with list 5 characters"
            }
        }else if textField == emailTextField{
            if isValid(textField.text!) == true && textField.text != ""{
                textField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
                self.emailErrorLable.isHidden = true
            }else{
                self.emailErrorLable.isHidden = false
                self.emailErrorLable.text = "Incorrect Email"
            }
        }else if textField == passwordTextField{
            if (textField.text?.count)! > 4 && textField.text?.count != 0{
                textField.resignFirstResponder()
                self.passwordErrorLable.isHidden = true
                userRgister()
            }else{
                self.passwordErrorLable.isHidden = false
                self.passwordErrorLable.text = "Password must contain 5 charecters"
            }
        }
        return true
    }
    
    func userRgister(){
        let user: Parameters = [
            "name": self.userNameTextField.text!,
            "email": self.emailTextField.text!,
            "password": self.passwordTextField.text!
        ]
        
        Alamofire.request("https://frozen-meadow-31076.herokuapp.com/api/users/register", method: .post, parameters: user, encoding: JSONEncoding.default).responseString {
            respone in
            if respone.result.isSuccess {
                switch respone.response?.statusCode {
                case 200:
                    self.stopAnimation()
                    
                    ////Save username and password on the device
                    let _: Bool = KeychainWrapper.standard.set(self.userNameTextField.text!, forKey: "userName")
                    let _: Bool = KeychainWrapper.standard.set(self.passwordTextField.text!, forKey: "password")

                    UIView.animate(withDuration: 1.0, animations: {
                        self.present(self.alertService.alert(mainTitle: "Yay!", descText: "Thank you for registering with us!", buttonTitle: "Continue", isGood: true, needButton: false), animated: true)
                    }, completion: { (finish) in
                        self.performSegue(withIdentifier: "registerToMap", sender: self)
                    })
                case 400:
                    self.stopAnimation()
                    self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: respone.result.value!, buttonTitle: "Ok", isGood: false, needButton: true), animated: true)
                default:
                    self.stopAnimation()
                    self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: respone.result.value!, buttonTitle: "Ok", isGood: false, needButton: true), animated: true)
                }
            }else{
                self.stopAnimation()
                self.present(self.alertService.alert(mainTitle: "Oopsy!", descText: respone.result.value!, buttonTitle: "Try again", isGood: false, needButton: true), animated: true)
            }
        }
        
   }
    
    func tapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        RegisterViewController.addGestureRecognizer(tapGesture)
    }
    
    @objc func tableViewTapped(){
        userNameTextField.endEditing(true)
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        view.frame.origin.y = 0
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
    
    //Email validation
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    //Animation
    func loginAnimation() {
        myView.isHidden = false
        animationView = AnimationView(name: "loadingAnimation")
        
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height:  150)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        myView.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        myView.frame = self.view.frame
        animationView.loopMode = .loop
        view.addSubview(myView)
        view.addSubview(animationView)
        self.animationView.play()
    }
    
    func stopAnimation() {
        self.animationView.stop()
        self.animationView.isHidden = true
        self.myView.isHidden = true
    }
}
