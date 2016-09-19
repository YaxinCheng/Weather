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
	let code: Int
	let dayTime: Bool
	
	init(rawValue: String, code: Int, day: Bool) {
		self.code = code
		
		let initializer: (String) -> (String, Bool) = {
			if let range = $0.range(of: " (day)") {
				return ($0.replacingCharacters(in: range, with: ""), true)
			} else if let range = $0.range(of: " (night)") {
				return ($0.replacingCharacters(in: range, with: ""), false)
			} else {
				return ($0, day)
			}
		}
		
		(self.rawValue, dayTime) = initializer(rawValue)
	}
	
	var videoName: String {
		switch code {
		case 32...34:
			return dayTime ? "weather_sunny" : "weather_clear"
		case 31:
			return "weather_clear"
		case 26...29:
			return dayTime ? "weather_cloudy_day" : "weather_cloudy_night"
		case 6, 8...12, 18, 40:
			return dayTime ? "weather_rain_day" : "weather_rain_night"
		case 19...22:
			return dayTime ? "weather_fog_day" : "weather_fog_night"
		case 30:
			return "weather_partly_sunny"
		case 44:
			return dayTime ? "weather_partly_cloud_day" : "weather_partly_cloud_night"
		case 5, 7, 13...17, 25, 41...43, 46:
			return dayTime ? "weather_snow_day" : "weather_snow_night"
		case 0...4, 37...39, 45, 47:
			return dayTime ? "weather_thunderstorm_day" : "weather_thunderstorm_night"
		case 23, 24:
			return dayTime ? "weather_windy_day" : "weather_windy_night"
		case 36:
			return "weather_hot"
		default:
			return ""
		}
	}
	
	var landscapeVideoName: String {
		switch code {
		case 32...34:
			return dayTime ? "weather_l_sunny" : "weather_l_clear"
		case 31:
			return "weather_l_clear"
		case 26...29:
			return dayTime ? "weather_l_cloudy_day" : "weather_l_cloudy_night"
		case 6, 8...12, 18, 40:
			return dayTime ? "weather_l_rain_day" : "weather_l_rain_night"
		case 19...22:
			return dayTime ? "weather_l_fog_day" : "weather_l_fog_night"
		case 30:
			return "weather_l_partly_sunny"
		case 44:
			return dayTime ? "weather_l_partly_cloud_day" : "weather_l_partly_cloud_night"
		case 5, 7, 13...17, 25, 41...43, 46:
			return dayTime ? "weather_l_snow_day" : "weather_l_snow_night"
		case 0...4, 37...39, 45, 47:
			return dayTime ? "weather_l_thunderstorm_day" : "weather_l_thunderstorm_night"
		case 23, 24:
			return dayTime ? "weather_l_windy_day" : "weather_l_windy_night"
		case 36:
			return "weather_l_hot"
		default:
			return ""
		}
	}
	
	var icon: UIImage {
		switch rawValue.lowercased() {
		case "foggy":
			let name = dayTime ? "foggy day" : "haze"
			return UIImage(named: name)!
		case "fair", "mostly clear":
			return UIImage(named: dayTime ? "sunny" : "clear")!
		case "mixed rain and sleet", "freezing rain":
			return UIImage(named: "mixed snow and sleet")!
		case "rain":
			return UIImage(named: "showers day")!
		case "sleet":
			return UIImage(named: dayTime ? "light snow shower day" : "light snow shower night")!
		case "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			return UIImage(named: "thunderstorms")!
		case "blustery", "breezy":
			return UIImage(named: "windy")!
		case "heavy snow", "light snow showers", "mostly cloudy", "partly cloudy", "showers":
			let suffix = dayTime ? "day" : "night"
			return UIImage(named: rawValue.lowercased() + " " + suffix)!
		case "isolated thundershowers", "scattered thundershowers":
			return UIImage(named: "thundershowers")!
		default:
			return UIImage(named: rawValue.lowercased()) ?? UIImage(named: "not available")!
		}
	}
	
	var iconName: String {
		switch rawValue.lowercased() {
		case "foggy":
			return dayTime ? "foggy day" : "haze"
		case "fair", "mostly clear":
			return dayTime ? "sunny" : "clear"
		case "mixed rain and sleet", "freezing rain":
			return "mixed snow and sleet"
		case "rain":
			return "showers day"
		case "sleet":
			return dayTime ? "light snow shower day" : "light snow shower night"
		case "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			return "thunderstorms"
		case "blustery", "breezy":
			return "windy"
		case "heavy snow", "light snow showers", "mostly cloudy", "partly cloudy", "showers":
			let suffix = dayTime ? "day" : "night"
			return rawValue.lowercased() + " " + suffix
		case "isolated thundershowers", "scattered thundershowers":
			return "thundershowers"
		default:
			return rawValue.lowercased()
		}
	}
}
