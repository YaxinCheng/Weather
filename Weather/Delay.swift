//
//  Delay.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

func Delay(time: Double, block: dispatch_block_t) {
	let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
	dispatch_after(delayTime, dispatch_get_main_queue(), block)
}