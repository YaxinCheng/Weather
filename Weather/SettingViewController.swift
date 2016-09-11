//
//  SettingViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
	
	private let units = [("Temperature", "Cel", "Fah"), ("Distance", "Mi", "Km"), ("Speed", "MPH", "KmPH"), ("Direction", "Compass", "Degree")]
	
	private let _DefaultIndex = 0
	private let _OptionalIndex = 1
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
}

// MARK: - Table view data source
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : units.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			return tableView.dequeueReusableCellWithIdentifier(Common.headerCellIdentifier) as! HeaderCell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(Common.unitCellIdentifier) as! UnitSettingCell
			let unit = units[indexPath.row]
			cell.unitNameLabel.text = unit.0
			cell.unitSegment.setTitle(unit.1, forSegmentAtIndex: _DefaultIndex)
			cell.unitSegment.setTitle(unit.2, forSegmentAtIndex: _OptionalIndex)
			let selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey(unit.0)
			cell.unitSegment.selectedSegmentIndex = selectedIndex
			return cell
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 114 : 44
	}
}
