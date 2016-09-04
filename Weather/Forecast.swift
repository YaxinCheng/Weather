//
//  Forecast.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Forecast {
	var highTemp: Double
	var lowTemp: Double
	let condition: WeatherCondition
	let conditionDescription: String
	let date: String
	
	init?(with JSON: NSDictionary) {
		guard
			let time = JSON["date"] as? String,
			let date = NSDate.date(string: time, format: "dd MMM yyyy"),
			let high = JSON["high"] as? Double,
			let low = JSON["low"] as? Double,
			let conditionString = JSON["text"] as? String
		else { return nil }
		self.date = date.formatDate()
		conditionDescription = conditionString
		highTemp = high
		lowTemp = low
		let timeZone = CityManager.sharedManager.currentCity?.timeZone ?? NSTimeZone.localTimeZone()
		let day = NSDateComponents(from: "6:00 am")! < NSDate().time(timeZone: timeZone) && NSDateComponents(from: "8:00 pm")! > NSDate().time(timeZone: timeZone)
		condition = WeatherCondition(rawValue: conditionString, day: day)
	}
}