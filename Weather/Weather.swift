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
	let conditionText: String
	let temprature: String
	let pressure: String
	let windTemperatue: String
	let sunriseTime: Int
	let sunsetTime: Int
	let visibility: String
	let windsDirection: String
	let humidity: String
	let country: String
	let region: String
	let city: String
	
	init?(with JSON: NSDictionary) {
		guard
			let temprature = JSON["temperatureInC"] as? String,
			let pressure = JSON["pressureInIN"] as? String,
			let windTemperatue = JSON["windChillInC"] as? String,
			let sunsetTime = (JSON["sunsetInLocalTime"] as? NSDateComponents)?.hour,
			let sunriseTime = (JSON["sunriseInLocalTime"] as? NSDateComponents)?.hour,
			let visibility = JSON["visibilityInMI"] as? String,
			let windsDirection = JSON["windDirectionInCompassPoints"] as? String,
			let humidity = JSON["humidity"] as? String,
			let condition = JSON["condition"] as? String,
			let country = JSON["country"] as? String,
			let region = JSON["region"] as? String,
			let city = JSON["city"] as? String
		else { return nil }
		self.temprature = temprature
		self.pressure = pressure
		self.windTemperatue = windTemperatue
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
		self.visibility = visibility
		self.windsDirection = windsDirection
		self.humidity = humidity
		self.country = country
		self.region = region
		self.city = city
		self.conditionText = Weather.formatWeather(condition)
		let hour = NSDate.date(from: NSDate().localTime())!.hour
		self.condition = WeatherCondition(rawValue: condition, day: hour > sunsetTime)!
	}
	
	private static func formatWeather(weather: String) -> String {
		return weather.stringByReplacingOccurrencesOfString(" (day)", withString: "").stringByReplacingOccurrencesOfString(" (night)", withString: "")
	}
}