//
//  CityLoader.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct CityLoader: PlaceLoadProtocol {
	var responseType: String = "json"
	var input: String
	
	init(input: String) {
		self.input = input
	}
	
	func process(json: NSDictionary?, callback: ((Any?) -> Void)?) {
		guard let JSON = json, let cityList = JSON["predictions"] as? [NSDictionary] else {
			callback?(nil)
			return
		}
		let cities = cityList.flatMap { City(from: $0) }
		callback?(cities)
	}
}