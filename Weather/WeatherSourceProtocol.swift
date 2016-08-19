//
//  WeatherSourceProtocol.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-12.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import Alamofire

protocol WeatherSourceProtocol {
	var api: String { get }
	var format: String { get }
}

extension WeatherSourceProtocol {
	var api: String {
		return "https://query.yahooapis.com/v1/public/yql?q="
	}
	
	var format: String {
		return "&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
	}
	
	func sendRequst(sql: WeatherSourceSQL, with completion: (Any?)->()) {
		guard let url = NSURL(string: api + sql.rawValue + format) else { return }
		let urlRequest = NSURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10 * 60)
		Alamofire.request(.GET, urlRequest).responseJSON { (response) in
			switch response.result {
			case .Success(let json):
				guard let JSON = json as? NSDictionary where JSON["error"] == nil else { return }
				completion(JSON)
			case .Failure(let error):
				completion(error)
			}
		}
	}
}
