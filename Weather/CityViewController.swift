//
//  CityViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class CityViewController: UITableViewController {
	
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
		} catch {
			print(error)
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension CityViewController: UISearchBarDelegate {
	func searchBarTextDidEndEditing(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		guard let name = searchBar.text where !name.isEmpty else { return }
		let loader = CityLoader(input: name)
		loader.sendRequest { [weak self] in
			guard let cities = $0 as? [City] else {
				self?.cityList = []
				return
			}
			self?.cityList = cities
		}
	}
	
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			searchBarTextDidEndEditing(searchBar)
		}
		return true
	}
}