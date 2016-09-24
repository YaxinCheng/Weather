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
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
	
	@IBAction func cancelButtonPressed(_ sender: AnyObject) {
		dismiss(animated: true, completion: nil)
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
			if let searchCell = cell as? SearchCell {
				searchCell.searchBar.delegate = self
			}
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: Common.cityCellIdentifier, for: indexPath)
		let city = cityList[indexPath.row]
		cell.textLabel?.text = city.name
		cell.detailTextLabel?.text = city.region
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let city = cityList[indexPath.row]
		do {
			try city.saveToCache()
			performSegue(withIdentifier: Common.unwindFromCityView, sender: nil)
		} catch {
			print(error)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 && indexPath.row == 0 {
			return 65
		}
		return UITableViewAutomaticDimension
	}
}

extension CitySearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		let searchVC = UISearchController(searchResultsController: nil)
		searchVC.hidesNavigationBarDuringPresentation = false
		searchVC.searchBar.placeholder = "Your City"
		searchVC.searchResultsUpdater = self
		searchVC.dimsBackgroundDuringPresentation = true
		searchVC.searchBar.sizeToFit()
		present(searchVC, animated: true, completion: nil)
		return false
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		let cityLoader = CityLoader()
		cityLoader.loadCity(city: text) { [weak self] (json) in
			self?.cityList = json.flatMap { City(from: $0) }
		}
	}
}
