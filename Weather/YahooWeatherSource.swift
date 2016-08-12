//
//  YahooWeatherSource.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-12.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import APTimeZones

struct YahooWeatherSource: WeatherSourceProtocol {
	func currentWeather(at city: City, complete: (Weather) -> Void) {
		let baseSQL = WeatherSourceSQLPatterns.weather
		let cityDescription = city.description
		let completeSQL = baseSQL.generateSQL(with: cityDescription)
		sendRequst(completeSQL) {
			guard let weatherJSON = $0 as? NSDictionary,
				let unwrapped = (weatherJSON["query"] as? NSDictionary)?["results"]?["channel"] as? Dictionary<String, AnyObject>
			else { return }
			let formattedJSON = self.formatJSON(unwrapped)
			guard let weather = Weather(with: formattedJSON) else { return }
			complete(weather)
		}
	}
	
	private func formatJSON(json: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
		var newJSON = Dictionary<String, AnyObject>()
		newJSON["temperature"] = ((json["item"]?["condition"] as? NSDictionary)?["temp"] as? NSString)?.doubleValue
		newJSON["condition"] = (json["item"]?["condition"] as? NSDictionary)?["text"]
		newJSON["windChill"] = json["wind"]?["chill"]
		newJSON["windSpeed"] = json["wind"]?["speed"]
		newJSON["windDirection"] = json["wind"]?["direction"]
		newJSON["humidity"] = json["atmosphere"]?["humidity"]
		newJSON["visibility"] = json["atmosphere"]?["visibility"]
		newJSON["pressure"] = json["atmosphere"]?["pressure"]
		newJSON["country"] = json["location"]?["country"]
		newJSON["region"] = json["location"]?["region"]
		newJSON["city"] = json["location"]?["city"]
		let sunrise = processTime(json["astronomy"]?["sunrise"] as? String)
		let sunset = processTime(json["astronomy"]?["sunset"] as? String)
		let latitude = (json["item"]?["lat"] as? NSString)?.doubleValue
		let longitude = (json["item"]?["long"] as? NSString)?.doubleValue
		guard let _ = dayNight(sunrise, sunset: sunset, latitude: latitude, longitude: longitude) else { return Dictionary() }
		newJSON["sunrise"] = sunrise
		newJSON["sunset"] = sunset
		
		return newJSON
	}
	
	private func processTime(time: String?) -> NSDateComponents? {
		
		guard let timeComponents = time?.characters.split(isSeparator: {$0 == " " || $0 == ":"}).map(String.init) where timeComponents.count >= 2 else { return nil }
		let elements = timeComponents.flatMap { Int($0) }
		let component = NSDateComponents()
		component.hour = elements[0] + (timeComponents[2] == "am" ? 0 : 12)
		component.minute = elements[1]
		return component
	}
	
	private func dayNight(sunrise: NSDateComponents?, sunset: NSDateComponents?, latitude: Double?, longitude: Double?) -> Bool? {
		guard sunrise != nil && sunset != nil && latitude != nil && longitude != nil else { return nil }
		let location = CLLocation(latitude: latitude!, longitude: longitude!)
		let timeZone = APTimeZones.sharedInstance().timeZoneWithLocation(location)
		CityManager.sharedManager.dayNight(sunrise!, sunset: sunset!, timeZone: timeZone)
		return CityManager.sharedManager.day
	}
	
	func conver(value: Double, from funit: WeatherUnit, to tunit: WeatherUnit) -> Double? {
		switch (funit, tunit) {
		case (.Fahrenheit, .Celsius):
			return (value - 32) / 1.8
		case (.Celsius, .Fahrenheit):
			return value * 1.8 + 32
		default:
			return nil
		}
	}
}