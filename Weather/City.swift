//
//  City.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

struct City: CustomStringConvertible {
	let name: String
	let province: String
	let country: String
	var region: String {
		return province + ", " + country
	}
	
	init?(from JSON: NSDictionary) {
		guard let terms = JSON["terms"] as? [NSDictionary] else { return nil }
		name = terms[0]["value"] as! String
		province = terms[1]["value"] as! String
		country = terms[2]["value"] as! String
	}
	
	var description: String {
		return name + ", " + region
	}
}