//
//  CityCell.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-04.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

class CityListCell: UITableViewCell {
	
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var deleteButton: UIButton!
	weak var delegate: CityListViewDelegate?
	
	@IBAction func deleteButtonPressed(sender: AnyObject) {
		delegate?.deleteCity(of: self)
	}
}
