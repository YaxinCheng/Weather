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
		popoverPresentationController?.backgroundColor = .clear
		let count = cityList.count
		if count < 6 {
			let height = (count + 1) * 44
			preferredContentSize = CGSize(width: 150, height: height)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return section == 0 ? 1 : cityList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.cityLocalCellIdentifier) as! CityLocalCell
			cell.nameLabel.text = "Local"
			cell.imageView?.image = UIImage(named: "local")
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Common.cityListCellIdentifier) as! CityListCell
			cell.delegate = self
			let city = cityList[indexPath.row]
			cell.cityLabel.text = city.name
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: Common.unwindBackMain, sender: nil)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier, let indexPath = tableView.indexPathForSelectedRow else { return }
		if identifier == Common.unwindBackMain {
			if indexPath.section != 0 {
				let city = cityList[indexPath.row]
				CityManager.sharedManager.currentCity = city
				CityManager.sharedManager.isLocal = false
			} else {
				CityManager.sharedManager.currentCity	= nil
				CityManager.sharedManager.isLocal = true
			}
		}
	}
}

extension CityListViewController: CityListViewDelegate {
	func deleteCity(of cell: CityListCell) {
		let alertFunction: ()->() = { [unowned self] in
			let alert = UIAlertController(title: "City Delete Failed", message: nil, preferredStyle: .alert)
			alert.addAction(.Cancel)
			self.present(alert, animated: true, completion: nil)
		}
		guard let indexPath = tableView.indexPath(for: cell) , indexPath.section != 0 else {
			alertFunction()
			return
		}
		do {
			let city = cityList.remove(at: indexPath.row)
			try city.deleteFromCache()
			tableView.deleteRows(at: [indexPath], with: .fade)
		} catch {
			alertFunction()
		}
	}
}
