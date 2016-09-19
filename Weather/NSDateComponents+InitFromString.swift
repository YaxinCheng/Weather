//
//  NSDateComponents+InitFromString.swift
//  WeatherKit
//
//  Created by Yaxin Cheng on 2016-08-23.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

extension DateComponents {
	/**
	Constructs a new object with description time string.
	
	Contruction will fail if the string is in a wrong format.
	
	- Parameter timeString: 
		Such as "2:30AM", "11:30PM"
	- returns: 
		An initialized object with .hour and .minute set, or nil if timeString is in a wrong format
	*/
	init?(from timeString: String) {
		self.init()
		let timeComponents = timeString.characters.split(whereSeparator: {$0 == " " || $0 == ":"}).map(String.init)
		guard timeComponents.count >= 2 else { return nil }
		let elements = timeComponents.flatMap { Int($0) }
		self.hour = elements[0] + (timeComponents[2].lowercased() == "am" ? 0 : 12)
		self.minute = elements[1]
	}
}

func > (lhs: DateComponents, rhs: DateComponents) -> Bool {
	return (lhs.hour! * 60 + lhs.minute!) > (rhs.hour! * 60 + rhs.minute!)
}

func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
	return (lhs.hour! * 60 + lhs.minute!) < (rhs.hour! * 60 + rhs.minute!)
}
