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
	var dataSource: [Forecast] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		let weatherStation = WeatherStation.sharedStation
		let city = CityManager.sharedManager.currentCity
		let completion: (Result<[Forecast]> -> Void) = { [weak self] in
			switch $0 {
			case .Success(let forecasts):
				self?.dataSource = forecasts
			case .Failure(let error):
				let alert = UIAlertController(title: "Error!", message: "\(error)", preferredStyle: .Alert)
				alert.addAction(.Cancel)
				self?.presentViewController(alert, animated: true, completion: nil)
			}
		}
		if city != nil {
			weatherStation.forecast(for: city!, completion: completion)
		} else {
			weatherStation.forecast(completion)
		}
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
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(Common.forcastCellidentifier, forIndexPath: indexPath) as! ForecastCell
			let forecast = dataSource[indexPath.row]
			cell.forecastLabel.text = forecast.conditionDescription
			cell.weekdayLabel.text = forecast.date
			cell.highTempLabel.text = forecast.highTemp
			cell.lowTempLabel.text = forecast.lowTemp
			return cell
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 114 : 80
	}
}