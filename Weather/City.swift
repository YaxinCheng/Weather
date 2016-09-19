//
//  City.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData.NSManagedObject
import CoreLocation.CLLocation

struct City: CustomStringConvertible {
	let name: String
	let province: String
	let country: String
	let woeid: String
	let latitude: Double
	let longitude: Double
	let timeZone: TimeZone
	var region: String {
		return province.isEmpty ? country : province + ", " + country
	}
	
	init?(from JSON: Dictionary<String, AnyObject>) {
		guard
			let name = JSON["name"] as? String,
			let country = JSON["country"] as? String,
			let woeid = JSON["woeid"] as? String,
			let province = JSON["admin1"] as? String,
			let latitude = (JSON["centroid"]?["latitude"] as? NSString)?.doubleValue,
			let longitude = (JSON["centroid"]?["longitude"] as? NSString)?.doubleValue,
			let timeZoneString = JSON["timezone"] as? String,
			let timeZone = TimeZone(identifier: timeZoneString)
		else { return nil }
		self.name = name
		self.woeid = woeid
		self.country = country
		self.province = province
		self.latitude = latitude
		self.longitude = longitude
		self.timeZone = timeZone
	}
	
	var description: String {
		return name + ", " + region
	}
}

extension City: PropertySerializable {
	var properties: [String : AnyObject] {
		var newDict = [String: AnyObject]()
		newDict["name"] = name as AnyObject?
		newDict["province"] = province as AnyObject?
		newDict["country"] = country as AnyObject?
		newDict["woeid"] = woeid as AnyObject?
		newDict["latitude"] = latitude as AnyObject?
		newDict["longitude"] = longitude as AnyObject?
		newDict["timezone"] = timeZone.identifier as AnyObject?
		return newDict
	}
	
	init(with managedObject: NSManagedObject) {
		name = managedObject.value(forKey: "name") as! String
		province = managedObject.value(forKey: "province") as! String
		country = managedObject.value(forKey: "country") as! String
		woeid = managedObject.value(forKey: "woeid") as! String
		latitude = managedObject.value(forKey: "latitude") as! Double
		longitude = managedObject.value(forKey: "longitude") as! Double
		timeZone = TimeZone(identifier: managedObject.value(forKey: "timezone") as! String)!
	}
}

extension City: Persistable {
	var primaryKeyAttribute: String {
		return "woeid"
	}
	
	var primaryKeyValue: AnyObject {
		return woeid as AnyObject
	}
}
