//
//  FlightTableViewCell.swift
//  TrvlAR
//
//  Created by Avery Lamp on 9/17/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {

    @IBOutlet weak var fullAirportLabel: UILabel!
    @IBOutlet weak var airportShortLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
