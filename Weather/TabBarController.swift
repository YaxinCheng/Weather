//
//  TabBarController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-10-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	
	override func viewWillLayoutSubviews() {
		var tabFrame = tabBar.frame
		tabFrame.size.height = 40
		tabFrame.origin.y = view.frame.size.height - 40
		tabBar.frame = tabFrame
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tabBar.backgroundImage = UIImage()
		tabBar.shadowImage = UIImage()
		tabBar.tintColor = .black
	}
}
