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
	fileprivate let manager: CLLocationManager
	override init() {
		manager = CLLocationManager()
		manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		super.init()
		manager.delegate = self
		if CLLocationManager.authorizationStatus() == .notDetermined {
			manager.requestWhenInUseAuthorization()
		}
	}
	
	var location: CLLocation? {
		set {
			guard newValue != nil else { return }
			let locationData = NSKeyedArchiver.archivedData(withRootObject: newValue!)
			let userDefault = UserDefaults.standard
			userDefault.set(locationData, forKey: Common.locationIdentifier)
			let centre = NotificationCenter.default
			let notification = Notification(name: Notification.Name(rawValue: LocationStorageNotification.locationUpdated.rawValue), object: nil)
			centre.post(notification)
		} get {
			let userDefault = UserDefaults.standard
			guard let locationData = userDefault.object(forKey: Common.locationIdentifier) as? Data,
				let location = NSKeyedUnarchiver.unarchiveObject(with: locationData) as? CLLocation
			else { return nil }
			return location
		}
	}
	
	func refreshLocation() {
		manager.startUpdatingLocation()
	}
}

extension LocationStorage: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		defer { manager.stopUpdatingLocation() }
		if locations.isEmpty {
			let notification = Notification(name: Notification.Name(rawValue: LocationStorageNotification.noNewLocation.rawValue), object: nil)
			NotificationCenter.default.post(notification)
			return
		}
		let location = locations.last!
		self.location = location
	}
}

enum LocationStorageNotification: String {
	case locationUpdated
	case noNewLocation
}
