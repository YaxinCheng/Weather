//
//  AnimationGenerator.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-09-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit

struct AnimationGenerator {
	func moveAnimation(axis axis: Axis, duration: Double, removeOnCompletion: Bool = true, fillMode: String = kCAFillModeBoth) -> CABasicAnimation {
		let path = axis == .x ? "position.x" : "position.y"
		let animation = CABasicAnimation(keyPath: path)
		animation.duration = duration
		animation.removedOnCompletion = removeOnCompletion
		animation.fillMode = fillMode
		return animation
	}
	
	func opacityAnimation(duration duration: Double, removeOnCompletion: Bool = true, fillMode: String = kCAFillModeBoth) -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.duration = duration
		animation.removedOnCompletion = removeOnCompletion
		animation.fillMode = fillMode
		return animation
	}
}

enum Axis {
	case x
	case y
}