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
import CoreLocation

class ViewController: UIViewController {

	var player: AVPlayer?
	weak var playerLayer: AVPlayerLayer?
	@IBOutlet weak var infoPanel: UIView!
	@IBOutlet weak var syncButton: UIButton!
	@IBOutlet weak var cityButton: UIButton!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var weatherConditionLabel: UILabel!
	@IBOutlet weak var realFeelingLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var windDirectionLabel: UILabel!
	@IBOutlet weak var visibilityLabel: UILabel!
	@IBOutlet weak var sunriseLabel: UILabel!
	@IBOutlet weak var sunsetLabel: UILabel!
	
	@IBOutlet weak var alterTempLabel: UILabel!
	@IBOutlet weak var alterHumidLabel: UILabel!
	@IBOutlet weak var alterPressureLabel: UILabel!
	
	private var animating: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		WeatherStation.sharedStation.locationStorage.refreshLocation()
		let station = WeatherStation.sharedStation
		station.all(weatherDidRefresh)
		infoPanel.layer.opacity = 0.7
		
		tabBarController?.tabBar.backgroundImage = UIImage()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loopVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.locationUpdated.rawValue, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.noNewLocation.rawValue, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		player?.pause()
	}
	
	func weatherDidRefresh(result: Result<Weather>) {
		switch result {
		case .Success(let weather):
			setupPlayer(weather.condition)
			setupLabels(weather)
		case .Failure(let error):
			let alert = UIAlertController(title: nil, message: "\(error)", preferredStyle: .Alert)
			alert.addAction(.Cancel)
			self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
			break
		}
	}
	
	func loopVideo() {
		player?.seekToTime(kCMTimeZero)
		player?.play()
	}
	
	func setupPlayer(weather: WeatherCondition) {
		guard let videoURL = NSBundle.mainBundle().URLForResource(weather.videoName, withExtension: "mp4") else { return }
		if player == nil {
			player = AVPlayer(URL: videoURL)
			player?.actionAtItemEnd = .None
			player?.muted = true
		} else {
			player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: videoURL))
		}
		let playerLayer = AVPlayerLayer(player: player)
		self.playerLayer = playerLayer
		playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		playerLayer.zPosition = -1
		playerLayer.frame = view.frame
		view.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	func setupLabels(weather: Weather) {
		cityButton.setTitle(weather.city, forState: .Normal)
		tempLabel.text = weather.temprature + "°C"
		weatherConditionLabel.text = weather.conditionText
		realFeelingLabel.text = weather.windTemperatue  + "°C"
		humidityLabel.text = weather.humidity + "%"
		windDirectionLabel.text = weather.windsDirection
		visibilityLabel.text = weather.visibility
		sunriseLabel.text = "\(weather.sunriseTime):00"
		sunsetLabel.text = "\(weather.sunsetTime):00"
		
		alterTempLabel.text = "Temprature: " + weather.temprature + "°C"
		alterHumidLabel.text = "Humidity: " + weather.humidity + "%"
		alterPressureLabel.text = "Pressure: " + weather.pressure + "IN"
	}
	
	func refreshWeather() {
		WeatherStation.sharedStation.all(weatherDidRefresh)
	}
	
	@IBAction func syncButtonPressedUp(sender: UIButton) {
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.duration = 2
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeForwards
		animation.fromValue = 2 * M_PI
		animation.toValue = 0
		sender.layer.addAnimation(animation, forKey: "rotation")
		refreshLocation()
	}
	
	@IBAction func touchToFullScreen() {
		if animating == true { return }
		animating = true
		if infoPanel.hidden == false {
			UIView.animateWithDuration(0.3, animations: { [unowned self] in
				self.infoPanel.center.y += (self.infoPanel.bounds.height + 48)
				self.alterTempLabel.alpha = 1
				self.alterHumidLabel.alpha = 1
				self.alterPressureLabel.alpha = 1
			}) { [unowned self] _ in
				self.infoPanel.hidden = true
				self.animating = false
			}
		} else {
			infoPanel.hidden = false
			syncButton.hidden = false
			UIView.animateWithDuration(0.3, animations: { [unowned self] in
				self.alterPressureLabel.alpha = 0
				self.alterHumidLabel.alpha = 0
				self.alterTempLabel.alpha = 0
				self.infoPanel.center.y -= (self.infoPanel.bounds.height + 48)
			}) { [unowned self] _ in
				self.animating = false
			}
		}
	}
	
	@IBAction func swipeDownPanel(sender: UISwipeGestureRecognizer) {
		touchToFullScreen()
	}
	
	func enterForeground() {
		player?.play()
		syncButtonPressedUp(syncButton)
	}
	
	func refreshLocation() {
		WeatherStation.sharedStation.locationStorage.refreshLocation()
	}
}