//
//  NSDate+Localization.swift
//  NewsHub
//
//  Created by Yaxin Cheng on 2016-07-24.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

extension Date {
	func formatDate() -> String {
		let dateFmt = DateFormatter()
		dateFmt.dateFormat = "EEEE, MMM dd"
		dateFmt.timeZone = TimeZone.autoupdatingCurrent
		return dateFmt.string(from: self)
	}
	
	func localTime() -> String {
		let dateFmt = DateFormatter()
		dateFmt.dateFormat = "yyyy-MM-dd hh:mm:ss"
		let localTimeZone = TimeZone.autoupdatingCurrent
		dateFmt.timeZone = localTimeZone
		return dateFmt.string(from: self)
	}
	
	func time(timeZone zone: TimeZone = .current) -> DateComponents {
		var calendar = Calendar.autoupdatingCurrent
		calendar.timeZone = zone
		let component = calendar.dateComponents([.hour, .minute], from: self)
		return component
	}
	
	static func date(string: String, format: String, timeZone zone: TimeZone = .current) -> Date? {
		let dateFmt = DateFormatter()
		dateFmt.dateFormat = format
		dateFmt.timeZone = zone
		guard let date = dateFmt.date(from: string) else { return nil }
		return date
	}
	
	func localized(timeZone zone: TimeZone = .current) -> Date {
		let seconds = Double(zone.secondsFromGMT(for: self))
		return Date(timeInterval: seconds, since: self)
	}
}
