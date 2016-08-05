//
//  Cacheable.swift
//  NewsHub
//
//  Created by Yaxin Cheng on 2016-07-17.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit.UIApplication
import CoreData

protocol Persistable: PropertySerializable {
	static var entityName: String { get }
	var primaryKeyAttribute: String { get }
	var primaryKeyValue: AnyObject { get }
	func saveToCache() throws
	static func restoreFromCache() throws -> [Self]
	func deleteFromCache() throws
}

extension Persistable {
	static var entityName: String {
		return "\(Self.self)"
	}
	
	func saveToCache() throws {
		let attributes = properties
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		if existing == false {
			let model = NSEntityDescription.insertNewObjectForEntityForName(Self.entityName, inManagedObjectContext: context)
			for (key, value) in attributes {
				model.setValue(value, forKey: key)
			}
			appDelegate.saveContext()
		} else {
			let fetch = NSFetchRequest(entityName: Self.entityName)
			let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
			fetch.predicate = NSPredicate(format:  predicateFmt)
			let model = try context.executeFetchRequest(fetch).first as! NSManagedObject
			for (key, value) in attributes {
				model.setValue(value, forKey: key)
			}
			appDelegate.saveContext()
		}
	}
	
	static func restoreFromCache() throws -> [Self] {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		let fetch = NSFetchRequest(entityName: entityName)
		let result = try context.executeFetchRequest(fetch) as! [NSManagedObject]
		return result.map { Self.init(with: $0) }
	}
	
	func deleteFromCache() throws {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		let fetch = NSFetchRequest(entityName: Self.entityName)
		let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
		fetch.predicate = NSPredicate(format: predicateFmt)
		for model in try context.executeFetchRequest(fetch) {
			context.deleteObject(model as! NSManagedObject)
		}
	}
	
	var existing: Bool {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		let fetch = NSFetchRequest(entityName: Self.entityName)
		let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
		fetch.predicate = NSPredicate(format: predicateFmt)
		return context.countForFetchRequest(fetch, error: nil) > 0
	}
}
