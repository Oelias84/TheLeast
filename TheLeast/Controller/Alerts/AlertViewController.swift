//
//  AlertViewController.swift
//  TheLeast
//
//  Created by Ofir Elias on 03/05/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLable: UILabel!
    @IBOutlet weak var massageContainer: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet var faceImage: UIImageView!
    
    var theTitle = String()
    var desc = String()
    var actionButtonText = String()
    var isGood = Bool()
    var isButton = Bool()
    
    var goodFace : UIImage = UIImage(named:"Good")!
    var badFace : UIImage = UIImage(named:"Bad")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    func setupView(){
        
        massageContainer.layer.cornerRadius = 10
        massageContainer.layer.shadowOpacity = 0.3
        massageContainer.layer.shadowRadius = 10
        massageContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        if isButton{
            self.button.isHidden = false
            self.uiButtonChane(button: button)
            button.setTitle(actionButtonText, for: .normal)
        }else{
            self.button.isHidden = true
        }
        titleLable.text! = theTitle
        descriptionLable.text! = desc
        
        if isGood {
            faceImage.image = goodFace
            titleLable.textColor = UIColor.blue
        }else{
            faceImage.image = badFace
            titleLable.textColor = UIColor.red
        }
        
    }
    
    @IBAction func button(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: button ui design
    func uiButtonChane(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 7
    }
}
