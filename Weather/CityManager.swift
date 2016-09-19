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
	fileprivate init() {}
	
	var currentCity: City? = nil {
		didSet {
			let notification = Notification(name: Notification.Name(rawValue: CityManagerNotification.currentCityDidChange.rawValue), object: nil)
			NotificationCenter.default.post(notification)
		}
	}
	
	var isLocal: Bool = true
}

enum CityManagerNotification: String {
	case currentCityDidChange
}
