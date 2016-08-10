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
	var currentCity: City? {
		didSet {
			let notification = NSNotification(name: CityNotification.CityDidChange.rawValue, object: nil)
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
	private init() {
		currentCity = nil
	}
	
	private(set) var sunrise: NSDateComponents?
	private(set) var sunset: NSDateComponents?
	private(set) var timeZone: NSTimeZone?
	
	mutating func dayNight(sunrise: NSDateComponents, sunset: NSDateComponents, timeZone: NSTimeZone) {
		self.sunrise = sunrise
		self.sunset = sunset
		self.timeZone = timeZone
	}
	
	var day: Bool? {
		guard let zone = timeZone, let sunriseTime = sunrise, let sunsetTime = sunset else { return nil }
		let date = NSDate().time(timeZone: zone)
		return date > sunriseTime && date < sunsetTime
	}
}

enum CityNotification: String {
	case CityDidChange
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