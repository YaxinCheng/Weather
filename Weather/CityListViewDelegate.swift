//
//  CityListViewDelegate.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol CityListViewDelegate: class {
	func deleteCity(of cell: CityListCell)
}