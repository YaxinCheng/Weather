//
//  CityViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import WeatherKit

class CitySearchViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	var cityList: Array<City>! = [] {
		didSet {
			tableView.reloadData()
		}
	}
	fileprivate let identifiers = [Common.headerCellIdentifier, Common.searchCellIdentifier, Common.subtitleCellIdentifier]
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.shared.statusBarStyle = .default
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier, let indexPath = tableView.indexPathForSelectedRow else {
			return
		}
		if identifier == Common.unwindFromCityView {
			let city = cityList[(indexPath as NSIndexPath).row]
			CityManager.sharedManager.currentCity = city
			let destinationVC = segue.destination as! ViewController
			destinationVC.refreshWeather()
		}
	}

}

// MARK: - Table view data source
extension CitySearchViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 3 : cityList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let identifier = identifiers[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
			cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.size.width * 2, bottom: 0, right: 0)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.cityCellIdentifier, for: indexPath) as! CityCell
			let city = cityList[indexPath.row]
			print(city)
			cell.nameLabel?.text = city.name
			cell.descriptionLabel?.text = city.region
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.section == 1 else { return }
		let city = cityList[indexPath.row]
		do {
			try city.saveToCache()
			tabBarController?.selectedIndex = 0
		} catch {
			print(error)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 && indexPath.row == 0 {
			return 65
		}
		else if indexPath.section == 1 {
			return 55
		}
		return UITableViewAutomaticDimension
	}
}

extension CitySearchViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n", let searchText = searchBar.text {
			searchBar.resignFirstResponder()
			let cityLoader = CityLoader()
			cityLoader.loadCity(city: searchText) { [weak self] (JSONs) in
				self?.cityList = JSONs.flatMap { City(from: $0) }
			}
		}
		return true
	}
}
