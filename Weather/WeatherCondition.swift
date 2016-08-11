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
	
	init(rawValue: String, day: Bool) {
		
		let initializer: (String) -> (String, Bool) = {
			if let range = $0.rangeOfString(" (day)") {
				return ($0.stringByReplacingCharactersInRange(range, withString: ""), true)
			} else if let range = $0.rangeOfString(" (night)") {
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
		case "clear":
			return "weather_clear"
		case "cloudy", "mostly cloudy":
			return dayTime ? "weather_cloudy_day" : "weather_cloudy_night"
		case "mixed rain and sleet", "drizzle", "freezing rain", "showers", "sleet":
			return dayTime ? "weather_rain_day" : "weather_rain_night"
		case "foggy", "dust", "haze", "smoky":
			return dayTime ? "weather_fog_day" : "weather_fog_night"
		case "mostly sunny":
			return "weather_partly_sunny"
		case "partlycloudy", "partly cloudy":
			return dayTime ? "weather_partly_cloud_day" : "weather_partly_cloud_night"
		case "snow", "mixed rain and snow", "mixed snow and sleet", "snow flurries", "light snow showers", "blowing snow", "hail", "cold", "heavy snow":
			return dayTime ? "weather_snow_day" : "weather_snow_night"
		case "thunderstorms", "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms", "isolated thundershowers":
			return dayTime ? "weather_thunderstorm_day" : "weather_thunderstorm_night"
		case "windy", "blustery":
			return dayTime ? "weather_windy_day" : "weather_windy_night"
		case "hot":
			return "weather_hot"
		default:
			return ""
		}
	}
	
	var landscapeVideoName: String {
		switch rawValue.lowercaseString {
		case "sunny", "fair":
			return dayTime ? "weather_l_sunny" : "weather_l_clear"
		case "clear":
			return "weather_l_clear"
		case "cloudy", "mostly cloudy":
			return dayTime ? "weather_l_cloudy_day" : "weather_l_cloudy_night"
		case "mixed rain and sleet", "drizzle", "freezing rain", "showers", "sleet":
			return dayTime ? "weather_l_rain_day" : "weather_l_rain_night"
		case "foggy", "dust", "haze", "smoky":
			return dayTime ? "weather_l_fog_day" : "weather_l_fog_night"
		case "mostly sunny":
			return "weather_l_partly_sunny"
		case "partlycloudy", "partly cloudy":
			return dayTime ? "weather_l_partly_cloud_day" : "weather_l_partly_cloud_night"
		case "snow", "mixed rain and snow", "mixed snow and sleet", "snow flurries", "light snow showers", "blowing snow", "hail", "cold", "heavy snow":
			return dayTime ? "weather_l_snow_day" : "weather_l_snow_night"
		case "thunderstorms", "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms", "isolated thundershowers":
			return dayTime ? "weather_l_thunderstorm_day" : "weather_l_thunderstorm_night"
		case "windy", "blustery":
			return dayTime ? "weather_l_windy_day" : "weather_l_windy_night"
		case "hot":
			return "weather_l_hot"
		default:
			return ""
		}
	}
	
	var icon: UIImage {
		switch rawValue.lowercaseString {
		case "foggy":
			let name = dayTime ? "foggy day" : "haze"
			return UIImage(named: name)!
		case "fair":
			return UIImage(named: dayTime ? "sunny" : "clear")!
		case "mixed rain and sleet", "freezing rain":
			return UIImage(named: "mixed snow and sleet")!
		case "rain":
			return UIImage(named: "showers day")!
		case "sleet":
			return UIImage(named: dayTime ? "light snow shower day" : "light snow shower night")!
		case "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			return UIImage(named: "thunderstorms")!
		case "blustery":
			return UIImage(named: "windy")!
		case "heavy snow", "light snow showers", "mostly cloudy", "partly cloudy", "showers":
			let suffix = dayTime ? "day" : "night"
			return UIImage(named: rawValue.lowercaseString + " " + suffix)!
		case "isolated thundershowers":
			return UIImage(named: "thundershowers")!
		default:
			return UIImage(named: rawValue.lowercaseString) ?? UIImage(named: "not available")!
		}
	}
	
	var iconName: String {
		switch rawValue.lowercaseString {
		case "foggy":
			return dayTime ? "foggy day" : "haze"
		case "fair":
			return dayTime ? "sunny" : "clear"
		case "mixed rain and sleet", "freezing rain":
			return "mixed snow and sleet"
		case "rain":
			return "showers day"
		case "sleet":
			return dayTime ? "light snow shower day" : "light snow shower night"
		case "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			return "thunderstorms"
		case "blustery":
			return "windy"
		case "heavy snow", "light snow showers", "mostly cloudy", "partly cloudy", "showers":
			let suffix = dayTime ? "day" : "night"
			return rawValue.lowercaseString + " " + suffix
		case "isolated thundershowers":
			return "thundershowers"
		default:
			return rawValue.lowercaseString
		}
	}
}