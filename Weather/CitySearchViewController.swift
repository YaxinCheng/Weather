//
//  CityViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import WeatherKit

class CitySearchViewController: UITableViewController {
	
	var cityList: Array<City>! = [] {
		didSet {
			tableView.reloadData()
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.shared.statusBarStyle = .default
		let searchBar = UISearchBar()
		searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
		searchBar.placeholder = "Search your city"
		searchBar.backgroundImage = UIImage()
		searchBar.delegate = self
		navigationItem.titleView = searchBar
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cityList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Common.cityCellIdentifier, for: indexPath)
		let city = cityList[(indexPath as NSIndexPath).row]
		cell.textLabel?.text = city.name
		cell.detailTextLabel?.text = city.region
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let city = cityList[(indexPath as NSIndexPath).row]
		do {
			try city.saveToCache()
			performSegue(withIdentifier: Common.unwindFromCityView, sender: nil)
		} catch {
			print(error)
		}
		tableView.deselectRow(at: indexPath, animated: true)
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

extension CitySearchViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			searchBar.resignFirstResponder()
			guard
				let name = searchBar.text , !name.isEmpty
			else { return true }
			let loader = CityLoader()
			loader.loadCity(city: name) { [weak self] (listOfJSON) in
				self?.cityList = listOfJSON.flatMap { City(from: $0) }
			}
		}
		return true
	}
}
