//
//  CityManager.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-03.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct CityManager {
	static var sharedManager = CityManager()
	private init() {}
	
	var currentCity: City? = nil {
		didSet {
			let notification = NSNotification(name: CityManagerNotification.currentCityDidChange.rawValue, object: nil)
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
}

enum CityManagerNotification: String {
	case currentCityDidChange
}