//
//  Delay.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-08-05.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import Foundation

func Delay(_ time: Double, block: @escaping ()->()) {
	let delayTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
	DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
}
