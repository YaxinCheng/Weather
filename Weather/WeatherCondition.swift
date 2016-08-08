//
//  WeatherCondition.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import UIKit.UIImage

struct WeatherCondition {
	let rawValue: String
	let dayTime: Bool
	
	init?(rawValue: String, day: Bool) {
		
		let initializer: (String) -> (String, Bool) = {
			if let range = $0.rangeOfString("(day)") {
				return ($0.stringByReplacingCharactersInRange(range, withString: ""), true)
			} else if let range = $0.rangeOfString("(night") {
				return ($0.stringByReplacingCharactersInRange(range, withString: ""), false)
			} else {
				return ($0, day)
			}
		}
		
		(self.rawValue, dayTime) = initializer(rawValue)
	}
	
	var videoName: String {
		switch rawValue.lowercaseString {
		case "sunny", "fair":
			return dayTime ? "weather_sunny" : "weather_clear"
		case "cloudy", "mostly cloudy":
			return dayTime ? "weather_cloudy_day" : "weather_cloudy_night"
		case "mixed rain and sleet", "drizzle", "freezing rain", "showers", "sleet":
			return dayTime ? "weather_rain_day" : "weather_rain_night"
		case "foggy", "dust", "haze", "smoky":
			return dayTime ? "weather_fog_day" : "weather_fog_night"
		case "partly cloudy", "mostly sunny":
			return "weather_partly_sunny"
		case "partlycloudy", "partly cloudy":
			return dayTime ? "weather_partly_cloud_day" : "weather_partly_cloud_night"
		case "snow", "mixed rain and snow", "mixed snow and sleet", "snow flurries", "light snow showers", "blowing snow", "hail", "cold":
			return dayTime ? "weather_snow_day" : "weather_snow_night"
		case "thunderstorm", "thunderstorms", "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			return dayTime ? "weather_thunderstorm_day" : "weather_thunderstorm_night"
		case "windy", "blustery":
			return dayTime ? "weather_windy_day" : "weather_windy_night"
		case "hot":
			return "weather_hot"
		default:
			return ""
		}
	}
	
	var icon: UIImage {
		return UIImage(named: "\(self)") ?? UIImage()
	}
}