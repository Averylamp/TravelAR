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
    
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.alpha = 0.8
        blurEffectView.layer.cornerRadius = 50
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = self.view.bounds
        //        blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        tableView.backgroundColor = nil
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.separatorStyle = .none
        
        reloadData()
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
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
    
    func reloadData(){
        var text = self.searchTextField.text
        if text == ""{
            text = self.searchTextField.placeholder
        }
        AzureAPIManager.shared().updateFlightInformation(location: text!) {
            print("Done refreshing flight data")
            self.tableView.reloadData()
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            if AzureAPIManager.shared().population != ""{
                
                self.populationLabel.text = "Population: \(AzureAPIManager.shared().population)"
            }else{
                self.populationLabel.text = "Population: "
            }
        }
    }
    
    @IBAction func collapseClicked(_ sender: Any) {
        reloadData()
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
    }
    
    @IBAction func presetButtonClicked(_ sender: UIButton) {
        self.searchTextField.text = sender.titleLabel?.text?.uppercased()
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
        reloadData()
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        reloadData()
    }
    
    
}

extension DataViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        NotificationCenter.default.post(name: toggleDataShowHideNotification, object: nil)
        reloadData()
        return true
    }
    
    
}

extension DataViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("Reloading cells")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AzureAPIManager.shared().flightData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FlightCell", for: indexPath) as? FlightTableViewCell{
            let data = AzureAPIManager.shared().flightData[indexPath.row]
            if let priceDouble = Double(data[1]){
                cell.priceLabel.text = "$\(Int(priceDouble))"
            }
            
            cell.fullAirportLabel.text = AzureAPIManager.shared().airportName
            cell.airportShortLabel.text = AzureAPIManager.shared().airportAbrev
            cell.dateLabel.text = "\(data[3]): \(data[4]), \(data[0])"
            cell.backgroundColor = nil
            
            
            
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "null")!
        }
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        if section == 0{
    //            if AzureAPIManager.shared().population != ""{
    //                let popLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
    //                popLabel.textAlignment = .center
    //                popLabel.font = UIFont(name: "Avenir-Roman", size: 20)
    //                popLabel.text = AzureAPIManager.shared().population
    //                popLabel.backgroundColor = nil
    //                popLabel.textColor = UIColor.white
    //                return popLabel
    //            }else{
    //                return nil
    //            }
    //        }
    //        return nil
    //    }
    
}
