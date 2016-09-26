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
		let completion: (([Forecast], Error?) -> Void) = { [weak self] in
			if $1 != nil || $0.isEmpty {
				let alert = UIAlertController(title: "Error!", message: "\($1!)", preferredStyle: .alert)
				alert.addAction(.Cancel)
				self?.present(alert, animated: true, completion: nil)
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.shared.statusBarStyle = .default
		forecastWeather()
	}
}

extension ForecastController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : dataSource.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (indexPath as NSIndexPath).section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.headerCellIdentifier, for: indexPath) as! HeaderCell
			let currentCity = CityManager.sharedManager.currentCity
			cell.titleLabel.text = currentCity?.name ?? "Forecast"
			cell.subtitleLabel.text = Date().formatDate()
			headerCell = cell
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.forcastCellidentifier, for: indexPath) as! ForecastCell
			let forecast = dataSource[(indexPath as NSIndexPath).row]
			cell.weatherImageView.image = forecast.condition.icon
			cell.forecastLabel.text = forecast.conditionDescription
			cell.weekdayLabel.text = (indexPath as NSIndexPath).row == 0 ? "Today" : forecast.date
			let temperatureUnit = WeatherStation.sharedStation.temperatureUnit
			cell.highTempLabel.text = String(format: "%.0f", round(forecast.highTemp)) + "\(temperatureUnit)"
			cell.lowTempLabel.text = String(format: "%.0f", round(forecast.lowTemp)) + "\(temperatureUnit)"
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (indexPath as NSIndexPath).section == 0 ? 114 : 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
