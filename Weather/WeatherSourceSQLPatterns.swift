//
//  WeatherSourceSQLPatterns.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-12.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

enum WeatherSourceSQLPatterns: String {
	case weather = "select location, wind, atmosphere, astronomy, item.lat, item.long, item.condition from weather.forecast where woeid in (select woeid from geo.places(1) where text=\"%@\")"
	case forecast = "select item.forecast from weather.forecast where woeid in (select woeid from geo.places(1) where text=\"%@\")"
	
	var sql: WeatherSourceSQL {
		return WeatherSourceSQL(rawValue: self.rawValue)
	}
	
	func generateSQL(with city: String) -> WeatherSourceSQL {
		let sql = String(format: self.rawValue, city)
		return WeatherSourceSQL(rawValue: sql)
	}
	
	func generateSQL(with citySQL: WeatherSourceSQL) -> WeatherSourceSQL {
		let sql = String(format: self.rawValue, citySQL.rawValue)
		return WeatherSourceSQL(rawValue: sql)	
	}
}