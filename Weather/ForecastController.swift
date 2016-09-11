//
//  ForecastController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class ForecastController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	weak var headerCell: HeaderCell?
	
	var dataSource: [Forecast] = [] {
		didSet {
			headerCell?.indicator.stopAnimating()
			tableView.reloadData()
		}
	}
	
	func forecastWeather() {
		let weatherStation = WeatherStation.sharedStation
		let city = CityManager.sharedManager.currentCity
		let completion: (([Forecast], ErrorType?) -> Void) = { [weak self] in
			if $1 != nil || $0.isEmpty {
				let alert = UIAlertController(title: "Error!", message: "\($1!)", preferredStyle: .Alert)
				alert.addAction(.Cancel)
				self?.presentViewController(alert, animated: true, completion: nil)
			} else {
				self?.dataSource = $0
			}
		}
		if city != nil {
			weatherStation.forecast(for: city!, completion: completion)
		} else {
			weatherStation.forecast(completion)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.sharedApplication().statusBarStyle = .Default
		forecastWeather()
	}
}

extension ForecastController: UITableViewDelegate, UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : dataSource.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier(Common.headerCellIdentifier, forIndexPath: indexPath) as! HeaderCell
			let currentCity = CityManager.sharedManager.currentCity
			cell.titleLabel.text = currentCity?.name ?? "Forecast"
			cell.subtitleLabel.text = NSDate().formatDate()
			headerCell = cell
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(Common.forcastCellidentifier, forIndexPath: indexPath) as! ForecastCell
			let forecast = dataSource[indexPath.row]
			cell.weatherImageView.image = forecast.condition.icon
			cell.forecastLabel.text = forecast.conditionDescription
			cell.weekdayLabel.text = indexPath.row == 0 ? "Today" : forecast.date
			let temperatureUnit = WeatherStation.sharedStation.temperatureUnit
			cell.highTempLabel.text = String(format: "%.0f", round(forecast.highTemp)) + "\(temperatureUnit)"
			cell.lowTempLabel.text = String(format: "%.0f", round(forecast.lowTemp)) + "\(temperatureUnit)"
			return cell
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 114 : 70
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}