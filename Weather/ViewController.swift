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
	
	private var animating = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		definesPresentationContext = true
		WeatherStation.sharedStation.locationStorage.refreshLocation()
		
		infoPanel.layer.opacity = 0.7
		
		tabBarController?.tabBar.backgroundImage = UIImage()
		tabBarController?.tabBar.shadowImage = UIImage()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loopVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.locationUpdated.rawValue, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.noNewLocation.rawValue, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshWeather()
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
		sunriseLabel.text = String(format: "%02d:$02d", weather.sunriseTime.hour, weather.sunriseTime.minute)
		sunsetLabel.text = String(format: "%02d:%02d", weather.sunsetTime.hour, weather.sunsetTime.minute)
		
		alterTempLabel.text = "Temprature: " + weather.temprature + "°C"
		alterHumidLabel.text = "Humidity: " + weather.humidity + "%"
		alterPressureLabel.text = "Pressure: " + weather.pressure + "IN"
	}
	
	func refreshWeather() {
		let city = CityManager.sharedManager.currentCity
		if city != nil {
			WeatherStation.sharedStation.all(for: city!, completion: weatherDidRefresh)
		} else {
			WeatherStation.sharedStation.all(weatherDidRefresh)
		}
	}
	
	@IBAction func syncButtonPressedUp(sender: UIButton) {
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.duration = 2
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeForwards
		animation.fromValue = 2 * M_PI
		animation.toValue = 0
		sender.layer.addAnimation(animation, forKey: "rotation")
		WeatherStation.sharedStation.clearCache()
		let city = CityManager.sharedManager.currentCity
		if city == nil {
			refreshLocation()
		} else {
			refreshWeather()
		}
	}
	
	@IBAction func touchToFullScreen() {
		guard animating == false else { return }
		animating = true
		let moveAnimation = CABasicAnimation(keyPath: "position.y")
		moveAnimation.duration = 0.3
		moveAnimation.removedOnCompletion = false
		moveAnimation.fillMode = kCAFillModeForwards
		
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.duration = moveAnimation.duration
		opacityAnimation.removedOnCompletion = moveAnimation.removedOnCompletion
		opacityAnimation.fillMode = kCAFillModeForwards
		if infoPanel.hidden == false {
			moveAnimation.fromValue = infoPanel.center.y
			moveAnimation.toValue = view.bounds.height + 100
			
			opacityAnimation.fromValue = 0
			opacityAnimation.toValue = 1
			
			infoPanel.layer.addAnimation(moveAnimation, forKey: nil)
			alterPressureLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			alterHumidLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			alterTempLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			
			Delay(moveAnimation.duration) { [weak self] in
				self?.infoPanel.hidden = true
				self?.alterTempLabel.layer.opacity = 1
				self?.alterHumidLabel.layer.opacity = 1
				self?.alterPressureLabel.layer.opacity = 1
				self?.animating = false
			}
		} else {
			infoPanel.hidden = false
			
			opacityAnimation.fromValue = 1
			opacityAnimation.toValue = 0
			moveAnimation.fromValue = view.bounds.height + 100
			moveAnimation.toValue = infoPanel.center.y
			
			alterTempLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			alterHumidLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			alterPressureLabel.layer.addAnimation(opacityAnimation, forKey: nil)
			
			infoPanel.layer.addAnimation(moveAnimation, forKey: nil)
			Delay(moveAnimation.duration) { [weak self] in
				self?.alterTempLabel.layer.opacity = 0
				self?.alterHumidLabel.layer.opacity = 0
				self?.alterPressureLabel.layer.opacity = 0
				self?.animating = false
			}
			
		}
	}
	
	@IBAction func cityButtonPressed(sender: UIButton) {
		performSegueWithIdentifier(Common.segueCityView, sender: nil)
	}
	
	@IBAction func cityButtonLongPressed(sender: UILongPressGestureRecognizer) {
		performSegueWithIdentifier(Common.segueCitySearch, sender: nil)
	}
	
	@IBAction func swipeDownPanel(sender: UISwipeGestureRecognizer) {
		touchToFullScreen()
	}
	
	// MARK: - Navigation
	@IBAction func prepareForUnwindSegue(segue: UIStoryboardSegue) {
		refreshWeather()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else { return }
		if identifier == Common.segueCityView {
			let destinationVC = segue.destinationViewController as! CityListViewController
			destinationVC.modalPresentationStyle = .Popover
			destinationVC.popoverPresentationController?.sourceView = cityButton
			destinationVC.popoverPresentationController?.delegate = self
			guard let popOver = destinationVC.popoverPresentationController else { return }
			popOver.sourceRect = CGRect(x: 0, y: 0, width: cityButton.frame.width, height: cityButton.frame.height)
		}
	}
	
	func enterForeground() {
		player?.play()
		syncButtonPressedUp(syncButton)
	}
	
	func refreshLocation() {
		WeatherStation.sharedStation.locationStorage.refreshLocation()
	}
}

extension ViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
}