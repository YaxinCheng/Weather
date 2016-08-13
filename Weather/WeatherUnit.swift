//
//  WeatherUnit.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-12.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

enum WeatherUnit {
	case Fahrenheit
	case Celsius
	
	static func convert(weather: Weather, from funit: WeatherUnit, to tunit: WeatherUnit) -> Weather {
		var converted = weather
		guard
			let temp = convert(Double(weather.temprature), from: funit, to: tunit),
			let windTemp = convert(Double(weather.windTemperatue), from: funit, to: tunit)
		else { return weather }
		converted.temprature = Int(temp)
		converted.windTemperatue = Int(windTemp)
		return converted
	}
	
	private static func convert(value: Double, from funit: WeatherUnit, to tunit: WeatherUnit) -> Double? {
		switch (funit, tunit) {
		case (.Fahrenheit, .Celsius):
			return (value - 32) / 1.8
		case (.Celsius, .Fahrenheit):
			return value * 1.8 + 32
		default:
			return nil
		}
	}
}