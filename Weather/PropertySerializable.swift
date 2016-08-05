//
//  PropertySerializable.swift
//  NewsHub
//
//  Created by Yaxin Cheng on 2016-07-17.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData.NSManagedObject

protocol PropertySerializable {
	var properties: [String: AnyObject] { get }
	init(with managedObject: NSManagedObject)
	static var attributeKeys: [String] { get }
}

extension PropertySerializable {
	static var attributeKeys: [String] {
		let mirror = Mirror(reflecting: self)
		guard let style = mirror.displayStyle where style == .Class || style == .Struct || style == .Dictionary else {
			return []
		}
		return mirror.children.flatMap { $0.label }
	}
}