//
//  CityListViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class CityListViewController: UITableViewController {
	
	var cityList: Array<City> = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		do {
			cityList = try City.restoreFromCache()
		} catch {
			print("Error: \(error)")
		}
		popoverPresentationController?.backgroundColor = .clearColor()
		let count = cityList.count
		if count < 6 {
			let height = (count + 1) * 44
			preferredContentSize = CGSize(width: 150, height: height)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return section == 0 ? 1 : cityList.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Common.cityListCellIdentifier, forIndexPath: indexPath) as! CityCell
		
		if indexPath.section == 0 {
			cell.cityLabel.text = "Local"
			cell.imageView?.image = UIImage(named: "local")
		} else {
			let city = cityList[indexPath.row]
			cell.cityLabel.text = city.name
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier(Common.unwindBackMain, sender: nil)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section != 0
	}
	
	override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			let city = cityList[indexPath.row]
			do {
				try city.deleteFromCache()
				cityList.removeAtIndex(indexPath.row)
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			} catch {
				let alert = UIAlertController(title: "City Delete Failed", message: nil, preferredStyle: .Alert)
				alert.addAction(.Cancel)
				presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier, let indexPath = tableView.indexPathForSelectedRow else { return }
		if identifier == Common.unwindBackMain {
			if indexPath.section != 0 {
				let city = cityList[indexPath.row]
				CityManager.sharedManager.currentCity = city
			} else {
				CityManager.sharedManager.currentCity = nil
			}
		}
	}
	
}
