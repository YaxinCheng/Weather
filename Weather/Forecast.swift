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
			let timeComponents = JSON["kYWADateComponents"] as? NSDateComponents,
			let high = JSON["highTemperatureForDay"] as? String,
			let low = JSON["lowTemperatureForDay"] as? String,
			let conditionString = JSON["shortDescription"] as? String,
			let cond = WeatherCondition(rawValue: conditionString, day: true)
		else { return nil }
		let time = "\(timeComponents.year)-\(timeComponents.month)-\(timeComponents.day)"
		let date = NSDate.date(string: time, format: "yyyy-MM-dd")
		self.date = date?.formatDate() ?? time
		conditionDescription = conditionString
		highTemp = high
		lowTemp = low
		condition = cond
	}
}