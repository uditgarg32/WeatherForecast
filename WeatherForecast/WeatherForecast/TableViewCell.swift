//
//  TableViewCell.swift
//  WeatherForecast
//
//  Created by Udit Garg on 6/1/21.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    //Create outlets for labels holding forecast data
    @IBOutlet weak var WeatherIcon: UIImageView!
    @IBOutlet weak var DayName: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var TempMax: UILabel!
    @IBOutlet weak var TempMin: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
