//
//  City.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData.NSManagedObject

struct City: CustomStringConvertible {
	let name: String
	let province: String
	let country: String
	let id: String
	var region: String {
		return province.isEmpty ? country : province + ", " + country
	}
	
	init?(from JSON: NSDictionary) {
		guard
			let terms = JSON["terms"] as? [NSDictionary] where terms.count > 0,
			let id = JSON["id"] as? String,
			let name = terms[0]["value"] as? String
		else { return nil }
		
		let province = terms[1]["value"] as? String ?? ""
		let country: String
		if terms.count > 2 {
			country = terms[2]["value"] as? String ?? ""
		} else {
			country = ""
		}
	
		self.name = name
		self.province = country.isEmpty ? "" : province
		self.country = country.isEmpty ? province : country
		self.id = id
	}
	
	var description: String {
		return name + ", " + region
	}
	
	var fullLocation: String {
		return country + "," + region + "," + name
	}
}

extension City: PropertySerializable {
	init(with managedObject: NSManagedObject) {
		name = managedObject.valueForKey("name") as! String
		province = managedObject.valueForKey("province") as! String
		country = managedObject.valueForKey("country") as! String
		id = managedObject.valueForKey("id") as! String
	}
	
	var properties: [String : AnyObject] {
		return Dictionary<String, AnyObject>(dictionaryLiteral: ("name", name), ("province", province), ("country", country), ("id", id))
	}
}

extension City: Persistable {
	var primaryKeyAttribute: String {
		return "id"
	}
	
	var primaryKeyValue: AnyObject {
		return id
	}
}