//
//  WeatherStation.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import YahooWeatherSource

struct WeatherStation {
	let locationStorage: LocationStorage
	private let weatherSource: YahooWeatherSource
	
	static var sharedStation = WeatherStation()
	
	var cachedWeather = [City: Weather]()
	var cachedCity: City? = nil
	
	private init() {
		weatherSource = YahooWeatherSource()
		locationStorage = LocationStorage()
	}
	
	func all(completion: (Weather?, ErrorType?) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.NotAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			completion(nil, error)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.NoAvailableLocation("Location is not available")
			completion(nil, error)
			return
		}
		weatherSource.locationParse(at: currentLocation) {
			guard let JSON = $0, let city = City(from: JSON) else { return }
			WeatherStation.sharedStation.cachedCity = city
			CityManager.sharedManager.currentCity = city
		}
	}
	
	func all(for city: City, completion: (Weather?, ErrorType?) -> Void) {
		weatherSource.currentWeather(city: city.name, province: city.province, country: city.country) {
			switch $0 {
			case .Success(let JSON):
				guard let weather = Weather(with: JSON) else {
					completion(nil, WeatherStationError.WeatherLoadError)
					return
				}
				WeatherStation.sharedStation.cachedWeather[city] = weather
				completion(weather, nil)
			case .Failure(let error):
				completion(nil, error)
			}
		}
	}
	
	func forecast(completion: ([Forecast], ErrorType?) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.NotAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			completion([], error)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.NoAvailableLocation("Location is not available")
			completion([], error)
			return
		}
		weatherSource.fivedaysForecast(at: currentLocation) {
			switch $0 {
			case .Success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				completion(forecasts, nil)
			case .Failure(let error):
				completion([], error)
			}
		}
	}
	
	func forecast(for city: City, completion: ([Forecast], ErrorType?) -> Void) {
		weatherSource.fivedaysForecast(city: city.name, province: city.province, country: city.country) {
			switch $0 {
			case .Success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				completion(forecasts, nil)
			case .Failure(let error):
				completion([], error)
			}
		}
	}
	
	private func saveForWidget(weather: Weather) {
		let userDefault = NSUserDefaults(suiteName: "group.NCGroup")
		userDefault?.setObject(CityManager.sharedManager.currentCity!.name, forKey: "City")
		userDefault?.setObject(weather.temprature, forKey: "Temperature")
		userDefault?.setObject(weather.condition.iconName, forKey: "Icon")
	}
}

enum WeatherStationError: ErrorType {
	case WeatherLoadError
}