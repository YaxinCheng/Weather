//
//  WeatherCondition.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import UIKit.UIImage

enum WeatherCondition {
	case sunny(day: Bool)
	case cloudy(day: Bool)
	case rainy(day: Bool)
	case fog(day: Bool)
	case partlySunny
	case partlyCloudy(day: Bool)
	case snow(day: Bool)
	case thunderstorm(day: Bool)
	case windy(day: Bool)
	case hot
	
	init?(rawValue: String, day: Bool?) {
		let dayTime = day ?? false
		switch rawValue.lowercaseString {
		case "sunny", "fair", "fair (day)":
			self = .sunny(day: dayTime)
		case "clear", "clear (night)", "fair (night)":
			self = .sunny(day: false)
		case "cloudy", "mostly cloudy":
			self = .cloudy(day: dayTime)
		case "mostly cloudy (night)", "partly cloudy (night)":
			self = .cloudy(day: false)
		case "mostly cloudy (day)":
			self = .cloudy(day: true)
		case "mixed rain and sleet", "drizzle", "freezing rain", "showers", "sleet":
			self = .rainy(day: dayTime)
		case "foggy", "dust", "haze", "smoky":
			self = .fog(day: dayTime)
		case "partly cloudy (day)", "mostly sunny":
			self = .partlySunny
		case "partlycloudy", "partly cloudy":
			self = .partlyCloudy(day: dayTime)
		case "snow", "mixed rain and snow", "mixed snow and sleet", "snow flurries", "light snow showers", "blowing snow", "hail", "cold":
			self = .snow(day: dayTime)
		case "thunderstorm", "thunderstorms", "tornado", "tropical storm", "hurricane", "severe thunderstorms", "scattered thunderstorms":
			self = .thunderstorm(day: dayTime)
		case "windy", "blustery":
			self = .thunderstorm(day: dayTime)
		case "hot":
			self = .hot
		default:
			return nil
		}
	}
	
	var videoName: String {
		switch self {
		case .sunny(day: let dayTime):
			return dayTime ? "weather_sunny" : "weather_clear"
		case .cloudy(day: let dayTime):
			return dayTime ? "weather_cloudy_day" : "weather_cloudy_night"
		case .rainy(day: let dayTime):
			return dayTime ? "weather_rain_day" : "weather_rain_night"
		case .fog(day: let dayTime):
			return dayTime ? "weather_fog_day" : "weather_fog_night"
		case .partlySunny:
			return "weather_partly_sunny"
		case .partlyCloudy(let dayTime):
			return dayTime ? "weather_partly_cloud_day" : "weather_partly_cloud_night"
		case .snow(day: let dayTime):
			return dayTime ? "weather_snow_day" : "weather_snow_night"
		case .thunderstorm(day: let dayTIme):
			return dayTIme ? "weather_thunderstorm_day" : "weather_thunderstorm_night"
		case .windy(day: let dayTime):
			return dayTime ? "weather_windy_day" : "weather_windy_night"
		case .hot:
			return "weather_hot"
		}
	}
	
	var icon: UIImage {
		return UIImage(named: "\(self)") ?? UIImage()
	}
}