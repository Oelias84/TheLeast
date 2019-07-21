//
//  CheapOrTippAlertControler.swift
//  TheLeast
//
//  Created by Ofir Elias on 12/05/2019.
//  Copyright © 2019 Ofir Elias. All rights reserved.
//

import UIKit

protocol CheapOrTippDelegate: class {
    func addButtonTapped(textFieldValue: String)
}

class CheapOrTippController : UIViewController {
    
    
    @IBOutlet weak var containerLayout: UIView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var topMarginConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var doorNumberText: UITextField!
    
    var delegate: CheapOrTippDelegate?
    var theTitle = String()
    var desc = String()
    var isGood = Bool()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    func setupView(){
        
        let screenHeight = self.view.frame.height
        
        if screenHeight <= 667.0 {
            topMarginConstrain.constant = 20
        }
        doorNumberText.layer.borderWidth = 1
        doorNumberText.layer.cornerRadius = 10
        doorNumberText.layer.borderColor = UIColor.gray.cgColor
        doorNumberText.becomeFirstResponder()

        titleLable.text = theTitle
        descLable.text = desc
        
        //MARK: Container appearance
        containerLayout.layer.cornerRadius = 17
        containerLayout.layer.shadowOpacity = 0.3
        containerLayout.layer.shadowRadius = 10
        containerLayout.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        //MARK: Button appearance
        addBtn.layer.borderWidth = 2
        addBtn.layer.borderColor = UIColor.blue.cgColor
        addBtn.layer.cornerRadius = 10
        
        if isGood {
            titleLable.textColor = UIColor.blue
        }else{
            titleLable.textColor = UIColor.red
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func screanTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addBtnAction(_ sender: Any) {
        doorNumberText.resignFirstResponder()
        delegate?.addButtonTapped(textFieldValue: doorNumberText.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
}
