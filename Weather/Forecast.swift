//
//  Forecast.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Forecast {
	let highTemp: String
	let lowTemp: String
	let condition: WeatherCondition
	let conditionDescription: String
	let date: String
	
	init?(with JSON: NSDictionary) {
		guard
			let time = JSON["date"] as? String,
			let date = NSDate.date(string: time, format: "dd MMM yyyy"),
			let high = (JSON["high"] as? NSString)?.doubleValue,
			let low = (JSON["low"] as? NSString)?.doubleValue,
			let conditionString = JSON["low"] as? String
		else { return nil }
		self.date = date.formatDate()
		conditionDescription = conditionString
		highTemp = String(Int(round(high)))
		lowTemp = String(Int(round(low)))
		condition = WeatherCondition(rawValue: conditionString, day: CityManager.sharedManager.day ?? true)
	}
}