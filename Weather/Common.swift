//
//  Common.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-29.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import UIKit.UIApplicationShortcutItem

struct Common {
	static let locationIdentifier = "LocationIdentifier"
	
	static let cityCellIdentifier = "cityCell"
	static let cityListCellIdentifier = "cityListCell"
	static let cityLocalCellIdentifier = "localCityCell"
	static let forcastCellidentifier = "ForecastCell"
	static let headerCellIdentifier = "HeaderCell"
	static let unitCellIdentifier = "unitSetting"
	static let searchCellIdentifier = "SearchCell"
	static let subtitleCellIdentifier = "subtitleCell"
	
	static let segueCityView = "showCityView"
	static let unwindBackMain = "citySelected"
	static let unwindFromCityView = "backFromCityView"
	
	static var shortCuts: Set<UIApplicationShortcutItem> = Set()
}
