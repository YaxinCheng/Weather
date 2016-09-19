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
	static func searchFromCache(_ predicate: NSPredicate) throws -> [Self]
	func deleteFromCache() throws
}

extension Persistable {
	static var entityName: String {
		return "\(Self.self)"
	}
	
	func saveToCache() throws {
		let attributes = properties
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		if existing == false {
			let model = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context)
			for (key, value) in attributes {
				model.setValue(value, forKey: key)
			}
			appDelegate.saveContext()
		} else {
			let fetch = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
			let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
			fetch.predicate = NSPredicate(format:  predicateFmt)
			let model = try context.fetch(fetch).first
			for (key, value) in attributes {
				model?.setValue(value, forKey: key)
			}
			appDelegate.saveContext()
		}
	}
	
	static func restoreFromCache() throws -> [Self] {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
		let result = try context.fetch(fetch)
		return result.map { Self.init(with: $0) }
	}
	
	static func deleteAllFromCache() throws {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
		let result = try context.fetch(fetch)
		for each in result {
			context.delete(each)
		}
		appDelegate.saveContext()
	}
	
	func deleteFromCache() throws {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		let fetch = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
		let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
		fetch.predicate = NSPredicate(format: predicateFmt)
		for model in try context.fetch(fetch) {
			context.delete(model)
		}
		appDelegate.saveContext()
	}
	
	static func searchFromCache(_ predicate: NSPredicate) throws -> [Self] {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		let fetch = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
		fetch.predicate = predicate
		return (try context.fetch(fetch)).map { Self.init(with: $0) }
	}
	
	var existing: Bool {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = appDelegate.managedObjectContext
		
		let fetch = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
		let predicateFmt = primaryKeyValue is String ? "\(primaryKeyAttribute) == \"\(primaryKeyValue)\"" : "\(primaryKeyAttribute) == \(primaryKeyValue)"
		fetch.predicate = NSPredicate(format: predicateFmt)
		let count = try? context.count(for: fetch)
		return count == nil ? false : count! != 0
	}
}
