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
	let windsSpeed: Double
	
	init?(with JSON: NSDictionary) {
		guard
			let temprature = JSON["temperature"] as? Double,
			let pressure = JSON["pressure"] as? String,
			let windTemperatue = JSON["windChill"] as? Double,
			let windsSpeed = JSON["windSpeed"] as? Double,
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
		let timeZone = CityManager.sharedManager.currentCity?.timeZone ?? NSTimeZone.localTimeZone()
		let day = sunriseTime < NSDate().time(timeZone: timeZone) && sunsetTime > NSDate().time(timeZone: timeZone)
		self.condition = WeatherCondition(rawValue: condition, day: day)
	}
}

func > (lhs: NSDateComponents, rhs: NSDateComponents) -> Bool {
	return (lhs.hour * 60 + lhs.minute) > (rhs.hour * 60 + rhs.minute)
}

func < (lhs: NSDateComponents, rhs: NSDateComponents) -> Bool {
	return (lhs.hour * 60 + lhs.minute) < (rhs.hour * 60 + rhs.minute)
}