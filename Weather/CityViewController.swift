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
		searchBar.keyboardType = .ASCIICapable
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
		}
	}
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

extension CityViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			searchBar.resignFirstResponder()
			guard
				let name = searchBar.text?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet()).stringByFoldingWithOptions(.DiacriticInsensitiveSearch, locale: NSLocale(localeIdentifier: "en_CA")).stringByReplacingOccurrencesOfString(" ", withString: "") where !name.isEmpty,
				let _ = NSURL(string: name)
				else { return true }
			let loader = CityLoader(input: name)
			loader.loads { [weak self] in
				self?.cityList = $0
			}
		}
		return true
	}
}