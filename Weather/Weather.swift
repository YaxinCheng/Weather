//
//  Weather.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import APTimeZones

struct Weather {
	let condition: WeatherCondition
	let conditionText: String
	let temprature: String
	let pressure: String
	let windTemperatue: String
	let sunriseTime: NSDateComponents
	let sunsetTime: NSDateComponents
	let visibility: String
	let windsDirection: String
	let humidity: String
	let country: String
	let region: String
	let city: String
	
	init?(with JSON: NSDictionary) {
		guard
			let temprature = (JSON["temperatureInC"] as? NSString)?.doubleValue,
			let pressure = JSON["pressureInIN"] as? String,
			let windTemperatue = JSON["windChillInC"] as? String,
			let sunsetTime = JSON["sunsetInLocalTime"] as? NSDateComponents,
			let sunriseTime = JSON["sunriseInLocalTime"] as? NSDateComponents,
			let visibility = JSON["visibilityInMI"] as? String,
			let windsDirection = JSON["windDirectionInCompassPoints"] as? String,
			let humidity = JSON["humidity"] as? String,
			let condition = JSON["condition"] as? String,
			let country = JSON["country"] as? String,
			let region = JSON["region"] as? String,
			let city = JSON["city"] as? String,
			let latitude = (JSON["latitude"] as? NSString)?.doubleValue,
			let longitude = (JSON["longitude"] as? NSString)?.doubleValue
		else { return nil }
		self.temprature = "\(Int(round(temprature)))"
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
		let location = CLLocation(latitude: latitude, longitude: longitude)
		let timeZone = APTimeZones.sharedInstance().timeZoneWithLocation(location)
		let hour = NSDate().localized(timeZone: timeZone).hour + 12 % 24
		let sunset = Double(sunsetTime.hour) + Double(sunsetTime.minute) / 60
		let sunrise = Double(sunriseTime.hour) + Double(sunriseTime.minute) / 60
		self.condition = WeatherCondition(rawValue: condition, day: Double(hour) < sunset && Double(hour) > sunrise)!
	}
	
	private static func formatWeather(weather: String) -> String {
		return weather.stringByReplacingOccurrencesOfString(" (day)", withString: "").stringByReplacingOccurrencesOfString(" (night)", withString: "")
	}
}