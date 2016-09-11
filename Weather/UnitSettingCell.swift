//
//  UnitSettingCell.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import WeatherKit

class UnitSettingCell: UITableViewCell {
	
	@IBOutlet weak var unitNameLabel: UILabel!
	@IBOutlet weak var unitSegment: UISegmentedControl!
	
	@IBAction func segmentChanged(sender: UISegmentedControl) {
		guard let name = unitNameLabel.text else { return }
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setInteger(sender.selectedSegmentIndex, forKey: name)
		unitSet(name, unit: sender.selectedSegmentIndex)
	}
	
	private func unitSet(unitName: String, unit: Int) {
		guard unit < 2 else { return }
		switch unitName {
		case "Temperature":
			let unit: TemperatureUnit = unit == 1 ? .fahrenheit : .celsius
			WeatherStation.sharedStation.temperatureUnit = unit
		case "Distance":
			let unit: DistanceUnit = unit == 1 ? .km : .mi
			WeatherStation.sharedStation.distanceUnit = unit
		case "Speed":
			let unit: SpeedUnit = unit == 1 ? .kmph : .mph
			WeatherStation.sharedStation.speedUnit = unit
		case "Direction":
			let unit: DirectionUnit = unit == 1 ? .degree : .direction
			WeatherStation.sharedStation.directionUnit = unit
		default:
			break
		}
	}
}
