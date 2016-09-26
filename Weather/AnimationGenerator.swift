//
//  AnimationGenerator.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

struct AnimationGenerator {
	func moveAnimation(axis: Axis, duration: Double, removeOnCompletion: Bool = true, fillMode: String = kCAFillModeBoth) -> CABasicAnimation {
		let path = axis.position
		let animation = CABasicAnimation(keyPath: path)
		animation.duration = duration
		animation.isRemovedOnCompletion = removeOnCompletion
		animation.fillMode = fillMode
		return animation
	}
	
	func opacityAnimation(duration: Double, removeOnCompletion: Bool = true, fillMode: String = kCAFillModeBoth) -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.duration = duration
		animation.isRemovedOnCompletion = removeOnCompletion
		animation.fillMode = fillMode
		return animation
	}
	
	func rotationAnimation(axis: Axis, duration: Double, removeOnCompletion: Bool = true, fillMode: String = kCAFillModeBoth, from fromValue: Double, to toValue: Double, repeatCount: Float = 0) -> CABasicAnimation {
		let path = axis.rotation
		let animation = CABasicAnimation(keyPath: path)
		animation.duration = duration
		animation.isRemovedOnCompletion = removeOnCompletion
		animation.fillMode = fillMode
		animation.fromValue = fromValue
		animation.toValue = toValue
		animation.repeatCount = repeatCount
		return animation
	}
}

enum Axis: String {
	case x
	case y
	case z
	
	var position: String {
		return "position." + rawValue
	}
	
	var rotation: String {
		return "transform.rotation." + rawValue
	}
}
