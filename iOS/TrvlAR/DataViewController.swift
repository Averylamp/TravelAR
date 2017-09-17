//
//  DataViewController.swift
//  TrvlAR
//
//  Created by Avery Lamp on 9/17/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var toggleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        
        
        NotificationCenter.default.addObserver(forName: toggleDataActionUpdatesNotification, object: nil, queue: nil) { (notification) in
            if let visible = notification.object as? Bool{
                UIView.transition(with: self.toggleButton, duration: 0.5, options: .curveLinear, animations: {
                    if visible{
                        self.toggleButton.setImage(#imageLiteral(resourceName: "collapseButton"), for: .normal)
                    }else{
                        self.toggleButton.setImage(#imageLiteral(resourceName: "planTripButton"), for: .normal)
                    }
                }, completion: nil)
            }
        }
    }
    
    @IBAction func collapseClicked(_ sender: Any) {
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
    }
    
    @IBAction func presetButtonClicked(_ sender: UIButton) {
        self.searchTextField.text = sender.titleLabel?.text?.uppercased()
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        
        
    }
    

}

extension DataViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
        return true
    }
    
    
}
