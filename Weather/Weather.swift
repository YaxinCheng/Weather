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
import CoreData.NSManagedObject

struct Weather {
	let condition: WeatherCondition
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
	private let location: (Double, Double)
	
	init?(with JSON: NSDictionary) {
		guard
			let temprature = (JSON["temperatureInC"] as? NSString)?.doubleValue,
			let pressure = JSON["pressureInIN"] as? String,
			let windTemperatue = (JSON["windChillInC"] as? NSString)?.doubleValue,
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
		self.windTemperatue = String(Int(round(windTemperatue)))
		self.sunriseTime = sunriseTime
		self.sunsetTime = sunsetTime
		self.visibility = visibility
		self.windsDirection = windsDirection
		self.humidity = humidity
		self.country = country
		self.region = region
		self.city = city
		self.location = (latitude, longitude)
		let location = CLLocation(latitude: latitude, longitude: longitude)
		let timeZone = APTimeZones.sharedInstance().timeZoneWithLocation(location)
		let time = NSDate().time(timeZone: timeZone)
		let currentTime = Double(time.hour) + Double(time.minute) / 60
		let sunset = Double(sunsetTime.hour) + Double(sunsetTime.minute) / 60
		let sunrise = Double(sunriseTime.hour) + Double(sunriseTime.minute) / 60
		self.condition = WeatherCondition(rawValue: condition, day: currentTime < sunset && currentTime >= sunrise)
	}
}

extension Weather: PropertySerializable {
	var properties: [String : AnyObject] {
		var properties = Dictionary<String, AnyObject>()
		properties["temperature"] = temprature
		properties["pressure"] = pressure
		properties["windTemperature"] = windTemperatue
		properties["sunriseHour"] = sunriseTime.hour
		properties["sunriseMinute"] = sunriseTime.minute
		properties["sunsetHour"] = sunsetTime.hour
		properties["sunsetMinute"] = sunsetTime.minute
		properties["visibility"] = visibility
		properties["windsDirection"] = windsDirection
		properties["humidity"] = humidity
		properties["country"] = country
		properties["region"] = region
		properties["city"] = city
		properties["condition"] = condition.rawValue
		properties["latitude"] = location.0
		properties["longitude"] = location.1
		properties["fullLocation"] = country + "," + region + "," + city
		return properties
	}
	
	init(with managedObject: NSManagedObject) {
		temprature = managedObject.valueForKey("temperature") as! String
		pressure = managedObject.valueForKey("pressure") as! String
		windTemperatue = managedObject.valueForKey("windTemperature") as! String
		let sunrise = (managedObject.valueForKey("sunriseHour") as! Int, managedObject.valueForKey("sunriseMinute") as! Int)
		sunriseTime = NSDateComponents()
		(sunriseTime.hour, sunriseTime.minute) = sunrise
		let sunset = (managedObject.valueForKey("sunsetHour") as! Int, managedObject.valueForKey("sunsetMinute") as! Int)
		sunsetTime = NSDateComponents()
		(sunsetTime.hour, sunsetTime.minute) = sunset
		visibility = managedObject.valueForKey("visibility") as! String
		windsDirection = managedObject.valueForKey("windsDirection") as! String
		humidity = managedObject.valueForKey("humidity") as! String
		country = managedObject.valueForKey("country") as! String
		region = managedObject.valueForKey("region") as! String
		city = managedObject.valueForKey("city") as! String
		location = (managedObject.valueForKey("latitude") as! Double, managedObject.valueForKey("longitude") as! Double)
		let timeZone = APTimeZones.sharedInstance().timeZoneWithLocation(CLLocation(latitude: location.0, longitude: location.1))
		let time = NSDate().time(timeZone: timeZone)
		let currentTime = Double(time.hour) + Double(time.minute) / 60
		let sunsetT = Double(sunsetTime.hour) + Double(sunsetTime.minute) / 60
		let sunriseT = Double(sunriseTime.hour) + Double(sunriseTime.minute) / 60
		
		let conditionRaw = managedObject.valueForKey("condition") as! String
		condition = WeatherCondition(rawValue: conditionRaw, day: currentTime >= sunriseT && currentTime < sunsetT)
	}
}

extension Weather: Persistable {
	var primaryKeyAttribute: String {
		return "fullLocation"
	}
	
	var primaryKeyValue: AnyObject {
		return country + "," + region + "," + city
	}
}