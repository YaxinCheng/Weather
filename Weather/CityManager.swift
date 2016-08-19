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
	var currentCity: City? = nil {
		didSet {
			let notification = NSNotification(name: CityManagerNotification.currentCityDidChange.rawValue, object: nil)
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
	private init() {
	}
	
	private(set) var sunrise: NSDateComponents?
	private(set) var sunset: NSDateComponents?
	
	mutating func dayNight(sunrise: NSDateComponents, sunset: NSDateComponents) {
		self.sunrise = sunrise
		self.sunset = sunset
	}
	
	var day: Bool? {
		guard let zone = currentCity?.timeZone, let sunriseTime = sunrise, let sunsetTime = sunset else { return nil }
		let date = NSDate().time(timeZone: zone)
		return date > sunriseTime && date < sunsetTime
	}
}

enum CityManagerNotification: String {
	case currentCityDidChange
}

private func > (lhs: NSDateComponents, rhs: NSDateComponents) -> Bool {
	let lhsTime = (Double(lhs.hour) + Double(lhs.minute) / 60)
	let rhsTime = (Double(rhs.hour) + Double(rhs.minute) / 60)
	return lhsTime > rhsTime
}

private func < (lhs: NSDateComponents, rhs: NSDateComponents) -> Bool {
	let lhsTime = (Double(lhs.hour) + Double(lhs.minute) / 60)
	let rhsTime = (Double(rhs.hour) + Double(rhs.minute) / 60)
	return lhsTime < rhsTime
}