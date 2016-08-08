//
//  NSDate+Localization.swift
//  NewsHub
//
//  Created by Yaxin Cheng on 2016-07-24.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

extension NSDate {
	func formatDate() -> String {
		let dateFmt = NSDateFormatter()
		dateFmt.dateFormat = "EEEE, MMMM dd"
		dateFmt.timeZone = NSTimeZone.localTimeZone()
		return dateFmt.stringFromDate(self)
	}
	
	func localTime() -> String {
		let dateFmt = NSDateFormatter()
		dateFmt.dateFormat = "yyyy-MM-dd hh:mm:ss"
		let localTimeZone = NSTimeZone.localTimeZone()
		dateFmt.timeZone = localTimeZone
		return dateFmt.stringFromDate(self)
	}
	
	func time(timeZone zone: NSTimeZone = .localTimeZone()) -> NSDateComponents {
		let calendar = NSCalendar.autoupdatingCurrentCalendar()
		calendar.timeZone = zone
		let component = calendar.components([.Hour, .Minute], fromDate: self)
		return component
	}
	
	static func date(string string: String, format: String, timeZone zone: NSTimeZone = .localTimeZone()) -> NSDate? {
		let dateFmt = NSDateFormatter()
		dateFmt.dateFormat = format
		dateFmt.timeZone = zone
		guard let date = dateFmt.dateFromString(string) else { return nil }
		return date
	}
	
	func localized(timeZone zone: NSTimeZone = .localTimeZone()) -> NSDate {
		let seconds = Double(zone.secondsFromGMTForDate(self))
		return NSDate(timeInterval: seconds, sinceDate: self)
	}
}