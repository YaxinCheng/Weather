//
//  CityLoader.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct CityLoader: WeatherSourceProtocol {
	let sql: WeatherSourceSQL
	
	init(input: String) {
		let baseSQL: WeatherSourceSQLPatterns = .city
		sql = baseSQL.generateSQL(with: input)
	}
}