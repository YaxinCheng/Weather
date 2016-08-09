//
//  PlaceProtocol.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import Alamofire

protocol PlaceLoadProtocol {
	var api: String { get }
	var key: String { get }
	var responseType: String { get set }
	var input: String { get set }
	var types: String { get }
	
	func sendRequest(method: Alamofire.Method, callback: ((Any?) -> Void)?)
	func process(json: NSDictionary?, callback: ((Any?) -> Void)?)
}

extension PlaceLoadProtocol {
	var api: String {
		return "https://maps.googleapis.com/maps/api/place/autocomplete"
	}
	
	var key: String {
		return "AIzaSyD2Wnq56wIWFCwVKxy9wLHqR1esFROl40Y"
	}
	
	var types: String {
		return "(cities)"
	}
	
	func sendRequest(method: Alamofire.Method = .GET, callback: ((Any?) -> Void)? = nil ) {
		Alamofire.request(method, api + "/" + responseType + "?input=" + input.lowercaseString + "&types=" + types + "&key=" + key).responseJSON { (response) in
			switch response.result {
			case .Success(let value):
				guard let json = value as? NSDictionary else { return }
				self.process(json, callback: callback)
			case .Failure(_):
				self.process(nil, callback: callback)
			}
		}
	}
}