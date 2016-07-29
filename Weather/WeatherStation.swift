//
//  WeatherStation.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherStation {
	static var sharedStation = WeatherStation()
	private let weatherManager: YWeatherAPI
	let locaitonManager: CLLocationManager
	
	private init() {
		weatherManager = YWeatherAPI.sharedManager()
		weatherManager.cacheEnabled = true
		weatherManager.cacheExpiryInMinutes = 20
		weatherManager.defaultTemperatureUnit = C
		locaitonManager = CLLocationManager()
		locaitonManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		if CLLocationManager.authorizationStatus() == .NotDetermined {
			locaitonManager.requestWhenInUseAuthorization()
		}
	}
	
	func all(completion: (Result<Weather>) -> Void) {
		defer {
			self.locaitonManager.stopUpdatingLocation()
		}
		let location: CLLocation?
		if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
			locaitonManager.startUpdatingLocation()
			location = locaitonManager.location
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
}