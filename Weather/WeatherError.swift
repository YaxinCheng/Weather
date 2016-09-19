//
//  WeatherError.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

enum WeatherError: Error {
	case notAuthorized(String)
	case restricted(String)
	case noRelatedWeather(String)
	case noAvailableLocation(String)
}
