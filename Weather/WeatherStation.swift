//
//  WeatherStation.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import WeatherKit

struct WeatherStation {
	let locationStorage: LocationStorage
	fileprivate var weatherSource: WeatherKit.WeatherStation
	
	static var sharedStation = WeatherStation()
	
	var temperatureUnit: TemperatureUnit {
		get {
			return weatherSource.temperatureUnit
		} set {
			weatherSource.temperatureUnit = newValue
		}
	}
	
	var speedUnit: SpeedUnit {
		get {
			return weatherSource.speedUnit
		} set {
			weatherSource.speedUnit = newValue
		}
	}
	
	var distanceUnit: DistanceUnit {
		get {
			return weatherSource.distanceUnit
		} set {
			weatherSource.distanceUnit = newValue
		}
	}
	
	var directionUnit: DirectionUnit {
		get {
			return weatherSource.directionUnit
		} set {
			weatherSource.directionUnit = newValue
		}
	}

	
	fileprivate init() {
		weatherSource = WeatherKit.WeatherStation()
		locationStorage = LocationStorage()
		let userDefault = UserDefaults.standard
		temperatureUnit = userDefault.integer(forKey: "Temperature") == 1 ? .fahrenheit : .celsius
		speedUnit = userDefault.integer(forKey: "Speed") == 1 ? .kmph : .mph
		distanceUnit = userDefault.integer(forKey: "Distance") == 1 ? .km : .mi
		directionUnit = userDefault.integer(forKey: "Direction") == 1 ? .degree : .direction
	}
	
	func all(_ completion: (Weather?, Error?) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.notAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			completion(nil, error)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.noAvailableLocation("Location is not available")
			completion(nil, error)
			return
		}
		let cityLoader = CityLoader()
		cityLoader.locationParse(location: currentLocation) {
			guard let JSON = $0, let city = City(from: JSON) else { return }
			CityManager.sharedManager.currentCity = city
		}
	}
	
	func all(for city: City, ignoreCache: Bool = false, completion: @escaping (Weather?, Error?) -> Void) {
		weatherSource.weather(city: city.name, province: city.province, country: city.country, ignoreCache: ignoreCache) {
			switch $0 {
			case .success(let JSON):
				guard let weather = Weather(with: JSON) else {
					completion(nil, WeatherStationError.weatherLoadError)
					return
				}
				if CityManager.sharedManager.isLocal {
					self.saveForWidget(weather)
				}
				completion(weather, nil)
			case .failure(let error):
				completion(nil, error)
			}
		}
	}
	
	func forecast(_ completion: @escaping ([Forecast], Error?) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.notAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			completion([], error)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.noAvailableLocation("Location is not available")
			completion([], error)
			return
		}
		weatherSource.forecast(location: currentLocation) {
			switch $0 {
			case .success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				completion(forecasts, nil)
			case .failure(let error):
				completion([], error)
			}
		}
	}
	
	func forecast(for city: City, completion: @escaping ([Forecast], Error?) -> Void) {
		weatherSource.forecast(city: city.name, province: city.province, country: city.country) {
			switch $0 {
			case .success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				completion(forecasts, nil)
			case .failure(let error):
				completion([], error)
			}
		}
	}
	
	fileprivate func saveForWidget(_ weather: Weather) {
		let userDefault = UserDefaults(suiteName: "group.NCGroup")
		userDefault?.set(CityManager.sharedManager.currentCity?.name ?? "Local", forKey: "City")
		userDefault?.set(weather.temprature, forKey: "Temperature")
		userDefault?.set(weather.condition.iconName, forKey: "Icon")
	}
	
	func clearCache() {
		weatherSource.clearCache()
	}
}

enum WeatherStationError: Error {
	case weatherLoadError
}
