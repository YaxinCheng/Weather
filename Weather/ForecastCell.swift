//
//  ForecastCell.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {
	
	@IBOutlet weak var weatherImageView: UIImageView!
	@IBOutlet weak var forecastLabel: UILabel!
	@IBOutlet weak var weekdayLabel: UILabel!
	@IBOutlet weak var highTempLabel: UILabel!
	@IBOutlet weak var lowTempLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
}
