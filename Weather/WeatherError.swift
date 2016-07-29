//
//  WeatherError.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

enum WeatherError: ErrorType {
	case NotAuthorized(String)
	case Restricted(String)
	case NoRelatedWeather(String)
	case NoAvailableLocation(String)
}