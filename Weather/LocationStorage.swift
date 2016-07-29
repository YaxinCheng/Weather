//
//  LocationStorage.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import CoreLocation

class LocationStorage: NSObject {
	private let manager: CLLocationManager
	override init() {
		manager = CLLocationManager()
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		super.init()
		manager.delegate = self
		if CLLocationManager.authorizationStatus() == .NotDetermined {
			manager.requestWhenInUseAuthorization()
		}
	}
	
	var location: CLLocation? {
		set {
			guard newValue != nil else { return }
			let locationData = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
			let userDefault = NSUserDefaults.standardUserDefaults()
			userDefault.setObject(locationData, forKey: Common.locationIdentifier)
		} get {
			let userDefault = NSUserDefaults.standardUserDefaults()
			guard let locationData = userDefault.objectForKey(Common.locationIdentifier) as? NSData,
				let location = NSKeyedUnarchiver.unarchiveObjectWithData(locationData) as? CLLocation
			else { return nil }
			return location
		}
	}
	
	func refreshLocation() {
		manager.startUpdatingLocation()
	}
}

extension LocationStorage: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		defer { manager.stopUpdatingLocation() }
		if locations.isEmpty { return }
		let location = locations.last!
		self.location = location
	}
}