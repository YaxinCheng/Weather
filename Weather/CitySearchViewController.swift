//
//  CityViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import YahooWeatherSource

class CitySearchViewController: UITableViewController {
	
	var cityList: Array<City>! = [] {
		didSet {
			tableView.reloadData()
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.sharedApplication().statusBarStyle = .Default
		let searchBar = UISearchBar()
		searchBar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
		searchBar.placeholder = "Search your city"
		searchBar.backgroundImage = UIImage()
		searchBar.delegate = self
		navigationItem.titleView = searchBar
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cityList.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Common.cityCellIdentifier, forIndexPath: indexPath)
		let city = cityList[indexPath.row]
		cell.textLabel?.text = city.name
		cell.detailTextLabel?.text = city.region
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let city = cityList[indexPath.row]
		do {
			try city.saveToCache()
			performSegueWithIdentifier(Common.unwindFromCityView, sender: nil)
		} catch {
			print(error)
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier, let indexPath = tableView.indexPathForSelectedRow else {
			return
		}
		if identifier == Common.unwindFromCityView {
			let city = cityList[indexPath.row]
			CityManager.sharedManager.currentCity = city
			let destinationVC = segue.destinationViewController as! ViewController
			destinationVC.refreshWeather()
		}
	}
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension CitySearchViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			searchBar.resignFirstResponder()
			guard
				let name = searchBar.text where !name.isEmpty
			else { return true }
			let loader = CityLoader()
			loader.loadCity(city: name) { [weak self] (listOfJSON) in
				self?.cityList = listOfJSON.flatMap { City(from: $0) }
			}
		}
		return true
	}
}