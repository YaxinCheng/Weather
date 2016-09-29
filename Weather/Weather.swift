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
	let sunriseTime: DateComponents
	let sunsetTime: DateComponents
	let visibility: Double
	let windsDirection: String
	let humidity: String
	let windsSpeed: Double
	let pressureTrend: String
	
	init?(with JSON: Dictionary<String, Any>) {
		guard
			let temprature = JSON["temperature"] as? Double,
			let pressure = JSON["pressure"] as? String,
			let windTemperatue = JSON["windChill"] as? Double,
			let windsSpeed = JSON["windSpeed"] as? Double,
			let sunsetTime = JSON["sunset"] as? DateComponents,
			let sunriseTime = JSON["sunrise"] as? DateComponents,
			let visibility = JSON["visibility"] as? Double,
			let windsDirection = JSON["windDirection"] as? String,
			let humidity = JSON["humidity"] as? String,
			let condition = JSON["condition"] as? String,
			let code = JSON["conditionCode"] as? Int,
			let pressureTrend = JSON["trend"] as? String
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
		self.pressureTrend = pressureTrend
		let timeZone = CityManager.sharedManager.currentCity?.timeZone ?? TimeZone.autoupdatingCurrent
		let day = sunriseTime < Date().time(timeZone: timeZone) && sunsetTime > Date().time(timeZone: timeZone)
		self.condition = WeatherCondition(rawValue: condition, code: code, day: day)
	}
}
