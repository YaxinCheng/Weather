//
//  SettingViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-08.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
	
	fileprivate let units = [("Temperature", "Cel", "Fah"), ("Distance", "Mi", "Km"), ("Speed", "MPH", "KmPH"), ("Direction", "Compass", "Degree")]
	
	fileprivate let _DefaultIndex = 0
	fileprivate let _OptionalIndex = 1
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.shared.statusBarStyle = .default
	}
}

// MARK: - Table view data source
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : units.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if (indexPath as NSIndexPath).section == 0 {
			return tableView.dequeueReusableCell(withIdentifier: Common.headerCellIdentifier) as! HeaderCell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.unitCellIdentifier) as! UnitSettingCell
			let unit = units[(indexPath as NSIndexPath).row]
			cell.unitNameLabel.text = unit.0
			cell.unitSegment.setTitle(unit.1, forSegmentAt: _DefaultIndex)
			cell.unitSegment.setTitle(unit.2, forSegmentAt: _OptionalIndex)
			let selectedIndex = UserDefaults.standard.integer(forKey: unit.0)
			cell.unitSegment.selectedSegmentIndex = selectedIndex
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return (indexPath as NSIndexPath).section == 0 ? 114 : 44
	}
}
