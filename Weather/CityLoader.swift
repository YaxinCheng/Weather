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
	let queue: dispatch_queue_t
	
	init(input: String) {
		let baseSQL: WeatherSourceSQLPatterns = .city
		sql = baseSQL.generateSQL(with: input)
		queue = dispatch_queue_create("CityQueue", nil)
	}
	
	func loads(complete: ([City]) -> Void) {
		dispatch_async(queue) {
			self.sendRequst(self.sql) {
				guard let citiesJSON = $0 as? NSDictionary else {
					dispatch_async(dispatch_get_main_queue()) {
						complete([])
					}
					return
				}
				let unwrapped: [NSDictionary]
				if let places = (citiesJSON["query"] as? NSDictionary)?["results"]?["place"] as? [NSDictionary] {
					unwrapped = places
				} else if let place = (citiesJSON["query"] as? NSDictionary)?["results"]?["place"] as? NSDictionary {
					unwrapped = [place]
				} else {
					complete([])
					return
				}
				let cities = unwrapped.flatMap { City(from: $0) }
				dispatch_async(dispatch_get_main_queue()) {
					complete(cities)
				}
			}
		}
	}
}