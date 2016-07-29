//
//  ViewController.swift
//  Weather
//
//  Created by Yaxin Cheng on 2016-07-28.
//  Copyright © 2016 Yaxin Cheng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

	var player: AVPlayer?
	weak var playerLayer: AVPlayerLayer?
	@IBOutlet weak var infoPanel: UIView!
	
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var weatherConditionLabel: UILabel!
	@IBOutlet weak var realFeelingLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var windDirectionLabel: UILabel!
	@IBOutlet weak var visibilityLabel: UILabel!
	@IBOutlet weak var sunriseLabel: UILabel!
	@IBOutlet weak var sunsetLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let station = WeatherStation.sharedStation
		station.all(weatherDidRefresh)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loopVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		infoPanel.layer.opacity = 0.7
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func weatherDidRefresh(result: Result<Weather>) {
		switch result {
		case .Success(let weather):
			setupPlayer(weather.condition)
			setupLabels(weather)
		case .Failure(let error):
			let alert = UIAlertController(title: nil, message: "\(error)", preferredStyle: .Alert)
			alert.addAction(.Cancel)
			self.presentViewController(alert, animated: true, completion: nil)
			break
		}
	}
	
	func loopVideo() {
		player?.seekToTime(kCMTimeZero)
		player?.play()
	}
	
	func setupPlayer(weather: WeatherCondition) {
		guard let videoURL = NSBundle.mainBundle().URLForResource(weather.videoName, withExtension: "mp4") else { return }
		player = AVPlayer(URL: videoURL)
		player?.actionAtItemEnd = .None
		player?.muted = true
		let playerLayer = AVPlayerLayer(player: player)
		self.playerLayer = playerLayer
		playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		playerLayer.zPosition = -1
		playerLayer.frame = view.frame
		view.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	func setupLabels(weather: Weather) {
		tempLabel.text = weather.temprature + "°C"
		weatherConditionLabel.text = weather.conditionText
		realFeelingLabel.text = weather.windTemperatue  + "°C"
		humidityLabel.text = weather.humidity + "%"
		windDirectionLabel.text = weather.windsDirection
		visibilityLabel.text = weather.visibility
		sunriseLabel.text = "\(weather.sunriseTime):00"
		sunsetLabel.text = "\(weather.sunsetTime):00"
	}
}

