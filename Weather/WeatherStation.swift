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
	
	private init() {
		weatherSource = YahooWeatherSource()
		locationStorage = LocationStorage()
	}
	
	func all(completion: (Result<Weather>) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.NotAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			let result = Result<Weather>.Failure(error)
			completion(result)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.NoAvailableLocation("Location is not available")
			let result = Result<Weather>.Failure(error)
			completion(result)
			return
		}
		weatherSource.locationParse(at: currentLocation) {
			guard let JSON = $0, let city = City(from: JSON) else { return }
			CityManager.sharedManager.currentCity = city
		}
	}
	
	func all(for city: City, completion: (Result<Weather>) -> Void) {
		weatherSource.currentWeather(city: city.name, province: city.province, country: city.country) {
			switch $0 {
			case .Success(let JSON):
				guard let weather = Weather(with: JSON) else {
					let error = WeatherStationError.WeatherLoadError
					let errorResult = Result<Weather>.Failure(error)
					completion(errorResult)
					return
				}
				let result = Result<Weather>.Success(weather)
				completion(result)
			case .Failure(let error):
				let errorResult = Result<Weather>.Failure(error)
				completion(errorResult)
			}
		}
	}
	
	func forecast(completion: (Result<[Forecast]>) -> Void) {
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			location = locationStorage.location
		} else {
			let error = WeatherError.NotAuthorized("Location service of the weather app is blocked, please turn it on in the setting app")
			let result = Result<[Forecast]>.Failure(error)
			completion(result)
			return
		}
		guard let currentLocation = location else {
			let error = WeatherError.NoAvailableLocation("Location is not available")
			let result = Result<[Forecast]>.Failure(error)
			completion(result)
			return
		}
		weatherSource.fivedaysForecast(at: currentLocation) {
			switch $0 {
			case .Success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				let result = Result<[Forecast]>.Success(forecasts)
				completion(result)
			case .Failure(let error):
				let result = Result<[Forecast]>.Failure(error)
				completion(result)
			}
		}
	}
	
	func forecast(for city: City, completion: (Result<[Forecast]>) -> Void) {
		weatherSource.fivedaysForecast(city: city.name, province: city.province, country: city.country) {
			switch $0 {
			case .Success(let JSONs):
				let forecasts = JSONs.flatMap { Forecast(with: $0) }
				let result = Result<[Forecast]>.Success(forecasts)
				completion(result)
			case .Failure(let error):
				let result = Result<[Forecast]>.Failure(error)
				completion(result)
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