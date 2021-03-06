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
	
	init?(with JSON: Dictionary<String, Any>) {
		guard
			let time = JSON["date"] as? String,
			let date = Date.date(string: time, format: "dd MMM yyyy"),
			let high = JSON["high"] as? Double,
			let low = JSON["low"] as? Double,
			let code = (JSON["code"] as? String)?.integerValue,
			let conditionString = JSON["text"] as? String
		else { return nil }
		self.date = date.formatDate()
		conditionDescription = conditionString
		highTemp = high
		lowTemp = low
		let timeZone = CityManager.sharedManager.currentCity?.timeZone ?? TimeZone.autoupdatingCurrent
		let day = DateComponents(from: "6:00 am")! < Date().time(timeZone: timeZone) && DateComponents(from: "8:00 pm")! > Date().time(timeZone: timeZone)
		condition = WeatherCondition(rawValue: conditionString, code: code, day: day)
	}
}
