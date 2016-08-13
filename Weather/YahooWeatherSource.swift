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
	func currentWeather(at city: City, complete: (Result<Weather>) -> Void) {
		let cityDescription = city.description
		loadWeatherData(at: cityDescription, complete: complete)
	}
	
	func currentWeather(at location: CLLocation, complete: (Result<Weather>) -> Void) {
		let geoCoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
			if error != nil {
				let errorResult = Result<Weather>.Failure(error!)
				complete(errorResult)
			} else {
				guard
					let mark = placeMarks?.first,
					let state = mark.addressDictionary?["State"] as? String,
					let country = mark.addressDictionary?["Country"] as? String,
					let city = mark.addressDictionary?["City"] as? String
				else {
					let error = Result<Weather>.Failure(YahooWeatherError.FailedFindingCity)
					complete(error)
					return
				}
				self.loadWeatherData(at: "\(city), \(state), \(country)", complete: complete)
			}
		}
	}
	
	func fivedaysForecast(at city: City, complete: (Result<[Forecast]> -> Void)) {
		loadForecasts(at: city.description, complete: complete)
	}
	
	func fivedaysForecast(at location: CLLocation, complete: (Result<[Forecast]> -> Void)) {
		let geoCoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
			if error != nil {
				let errorResult = Result<[Forecast]>.Failure(error!)
				complete(errorResult)
			} else {
				guard
					let mark = placeMarks?.first,
					let state = mark.addressDictionary?["State"] as? String,
					let country = mark.addressDictionary?["Country"] as? String,
					let city = mark.addressDictionary?["City"] as? String
					else {
						let error = Result<[Forecast]>.Failure(YahooWeatherError.FailedFindingCity)
						complete(error)
						return
				}
				self.loadForecasts(at: "\(city), \(state), \(country)", complete: complete)
			}
		}
	}
	
	private func loadWeatherData(at locationString: String, complete: (Result<Weather>) -> Void) {
		let baseSQL:WeatherSourceSQLPatterns = .weather
		let completeSQL = baseSQL.generateSQL(with: locationString)
		sendRequst(completeSQL) {
			guard let weatherJSON = $0 as? NSDictionary,
				let unwrapped = (weatherJSON["query"] as? NSDictionary)?["results"]?["channel"] as? Dictionary<String, AnyObject>
				else {
					let error = Result<Weather>.Failure(YahooWeatherError.LoadFailed)
					complete(error)
					return
			}
			let formattedJSON = self.formatWeatherJSON(unwrapped)
			guard let weather = Weather(with: formattedJSON) else { return }
			let result = Result<Weather>.Success(WeatherUnit.convert(weather, from: .Fahrenheit, to: .Celsius))
			complete(result)
		}
	}
	
	private func loadForecasts(at locationString: String, complete: (Result<[Forecast]>) -> Void) {
		let baseSQL:WeatherSourceSQLPatterns = .forecast
		let completeSQL = baseSQL.generateSQL(with: locationString)
		sendRequst(completeSQL) {
			guard let weatherJSON = $0 as? NSDictionary,
				let unwrapped = (((weatherJSON["query"] as? NSDictionary)?["results"] as? NSDictionary)?["channel"] as? NSDictionary)?["forecast"]?["item"] as? [Dictionary<String, AnyObject>]
				else {
					let error = Result<[Forecast]>.Failure(YahooWeatherError.LoadFailed)
					complete(error)
					return
			}
			let forecasts = unwrapped.flatMap { Forecast(with: $0) }
			let result = Result<[Forecast]>.Success(forecasts)
			complete(result)
		}
	}
	
	private func formatWeatherJSON(json: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
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
	

}

enum YahooWeatherError: ErrorType {
	case LoadFailed
	case FailedFindingCity
}