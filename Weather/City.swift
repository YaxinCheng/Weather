//
//  City.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData.NSManagedObject
import APTimeZones
import CoreLocation.CLLocation

struct City: CustomStringConvertible {
	let name: String
	let province: String
	let country: String
	let woeid: String
	let latitude: Double
	let longitude: Double
	let timeZone: NSTimeZone
	var region: String {
		return province.isEmpty ? country : province + ", " + country
	}
	
	init?(from JSON: NSDictionary) {
		guard
			let name = JSON["name"] as? String,
			let country = JSON["country"] as? String,
			let woeid = JSON["woeid"] as? String,
			let province = JSON["admin1"] as? String,
			let latitude = (JSON["centroid"]?["latitude"] as? NSString)?.doubleValue,
			let longitude = (JSON["centroid"]?["latitude"] as? NSString)?.doubleValue,
			let timeZoneString = JSON["timezone"] as? String,
			let timeZone = NSTimeZone(name: timeZoneString)
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
		newDict["name"] = name
		newDict["province"] = province
		newDict["country"] = country
		newDict["woeid"] = woeid
		newDict["latitude"] = latitude
		newDict["longitude"] = longitude
		newDict["timezone"] = timeZone.name
		return newDict
	}
	
	init(with managedObject: NSManagedObject) {
		name = managedObject.valueForKey("name") as! String
		province = managedObject.valueForKey("province") as! String
		country = managedObject.valueForKey("country") as! String
		woeid = managedObject.valueForKey("woeid") as! String
		latitude = managedObject.valueForKey("latitude") as! Double
		longitude = managedObject.valueForKey("longitude") as! Double
		timeZone = NSTimeZone(name: managedObject.valueForKey("timezone") as! String)!
	}
}

extension City: Persistable {
	var primaryKeyAttribute: String {
		return "woeid"
	}
	
	var primaryKeyValue: AnyObject {
		return woeid
	}
}