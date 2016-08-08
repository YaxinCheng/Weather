//
//  CityManager.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct CityManager {
	static var sharedManager = CityManager()
	var currentCity: City?
	
	private init() {
		currentCity = nil
	}
}