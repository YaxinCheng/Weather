//
//  TodayViewController.swift
//  Weather Widget
//
//  Created by Yaxin Cheng on 2016-08-11.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	
	@IBOutlet weak var weatherIconView: UIImageView!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var viewControl: UIControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view from its nib.
		let userDefault = UserDefaults(suiteName: "group.NCGroup")
		guard
			let city = userDefault?.string(forKey: "City"),
			let temperature = userDefault?.string(forKey: "Temperature"),
			let icon = userDefault?.string(forKey: "Icon")
		else { return }
		weatherIconView.image = UIImage(named: icon)
		cityLabel.text = city
		tempLabel.text = temperature + "°C"
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		// Perform any setup necessary in order to update the view.
		
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
		
		completionHandler(NCUpdateResult.newData)
	}
	
	@IBAction func viewTouched(_ sender: AnyObject) {
		extensionContext?.open(URL(string: "weatherX://main")!, completionHandler: nil)
	}
	
	func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		var newMargin = defaultMarginInsets
		newMargin.bottom = 10
		newMargin.left = 10
		return newMargin
	}
}
