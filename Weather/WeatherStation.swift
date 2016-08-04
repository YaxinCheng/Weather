//
//  WeatherStation.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation
import YWeatherAPI

struct WeatherStation {
	static var sharedStation = WeatherStation()
	private let weatherManager: YWeatherAPI
	let locationStorage: LocationStorage
	
	private init() {
		weatherManager = YWeatherAPI.sharedManager()
		weatherManager.cacheEnabled = true
		weatherManager.cacheExpiryInMinutes = 20
		weatherManager.defaultTemperatureUnit = C
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
		weatherManager.allCurrentConditionsForCoordinate(currentLocation, success: { (JSON) in
			guard let weather = Weather(with: JSON) else {
				return
			}
			let result = Result<Weather>.Success(weather)
			completion(result)
			}) { (response, error) in
			let result = Result<Weather>.Failure(error)
			completion(result)
		}
	}
	
	func all(for city: City, completion: (Result<Weather>) -> Void) {
		weatherManager.allCurrentConditionsForLocation(city.description, success: { (JSON) in
			guard let weather = Weather(with: JSON) else {
				return
			}
			let result = Result<Weather>.Success(weather)
			completion(result)
			}) { (response,  error) in
			let result = Result<Weather>.Failure(error)
			completion(result)
		}
	}
}