//
//  Weather.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Weather {
	let condition: WeatherCondition
	var temprature: Int
	let pressure: String
	var windTemperatue: Int
	let sunriseTime: NSDateComponents
	let sunsetTime: NSDateComponents
	let visibility: String
	let windsDirection: String
	let humidity: String
	let windsSpeed: String
	
	init?(with JSON: NSDictionary) {
		guard
			let temprature = JSON["temperature"] as? Double,
			let pressure = JSON["pressure"] as? String,
			let windTemperatue = (JSON["windChill"] as? NSString)?.doubleValue,
			let windsSpeed = JSON["windSpeed"] as? String,
			let sunsetTime = JSON["sunset"] as? NSDateComponents,
			let sunriseTime = JSON["sunrise"] as? NSDateComponents,
			let visibility = JSON["visibility"] as? String,
			let windsDirection = JSON["windDirection"] as? String,
			let humidity = JSON["humidity"] as? String,
			let condition = JSON["condition"] as? String
		else { return nil }
		self.temprature = Int(round(temprature))
		self.pressure = pressure
		self.windTemperatue = Int(round(windTemperatue))
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
		self.visibility = visibility
		self.windsDirection = windsDirection
		self.humidity = humidity
		self.windsSpeed = windsSpeed
		self.condition = WeatherCondition(rawValue: condition, day: CityManager.sharedManager.day!)
	}
}