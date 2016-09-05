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
	@IBOutlet weak var pressureLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var visibilityLabel: UILabel!
	@IBOutlet weak var sunriseLabel: UILabel!
	@IBOutlet weak var sunsetLabel: UILabel!
	@IBOutlet weak var conditionIcon: UIImageView!
	@IBOutlet weak var pressureTrendLabel: UILabel!
	
	@IBOutlet weak var windsTempLabel: UILabel!
	@IBOutlet weak var windsDirectionLabel: UILabel!
	@IBOutlet weak var windsSpeedLabel: UILabel!
	
	var currentWeather: Weather! {
		didSet {
			guard let weather = currentWeather else { return }
			setupLabels(weather)
			setupPlayer(weather.condition)
		}
	}
	
	var backgroundView: UIImageView!
	private var animating = false
	
	// MARK: - Set up the view
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		definesPresentationContext = true
		WeatherStation.sharedStation.locationStorage.refreshLocation()
		
		infoPanel.layer.opacity = 0.7
		
		tabBarController?.tabBar.backgroundImage = UIImage()
		tabBarController?.tabBar.shadowImage = UIImage()
		tabBarController?.tabBar.tintColor = view.tintColor
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loopVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(enterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: CityManagerNotification.currentCityDidChange.rawValue, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.locationUpdated.rawValue, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshWeather), name: LocationStorageNotification.noNewLocation.rawValue, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshWeather()
		UIApplication.sharedApplication().statusBarStyle = .LightContent
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		for eachLayer in backgroundView?.layer.sublayers ?? [] {
			if eachLayer is AVPlayerLayer {
				eachLayer.removeFromSuperlayer()
			}
		}
		player?.pause()
	}
	
	func orientationDidChange() {
		if let weather = currentWeather {
			setupLabels(weather)
			setupPlayer(weather.condition)
		}
	}
	
	func loopVideo() {
		player?.seekToTime(kCMTimeZero)
		player?.play()
	}
	
	func setupPlayer(weather: WeatherCondition) {
		let name = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? weather.videoName : weather.landscapeVideoName
		guard let videoURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp4") else { return }
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
		playerLayer.frame = backgroundView?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
		backgroundView.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	func setupLabels(weather: Weather) {
		if backgroundView != nil {
			backgroundView.removeFromSuperview()
		}
		
		let name = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? weather.condition.videoName : weather.condition.landscapeVideoName
		backgroundView = UIImageView(image: UIImage(named: name)!)
		if UI_USER_INTERFACE_IDIOM() == .Phone {
			backgroundView.frame = UIScreen.mainScreen().bounds
		} else if UI_USER_INTERFACE_IDIOM() == .Pad {
			let screenFrame = (UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
			let width = max(screenFrame.0, screenFrame.1)
			let height = screenFrame.0 == width ? screenFrame.1 : screenFrame.0
			let frame = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? CGRect(x: 0, y: 0, width: height, height: width) : CGRect(x: 0, y: 0, width: width, height: height)
			backgroundView.frame = frame
		}
		
		backgroundView.contentMode = .ScaleToFill
		view.insertSubview(backgroundView, atIndex: 0)
		
		if let city = CityManager.sharedManager.currentCity {
			cityButton.setTitle(city.name, forState: .Normal)
		} else {
			let name = WeatherStation.sharedStation.cachedCity?.name ?? "Local"
			cityButton.setTitle(name, forState: .Normal)
		}
		tempLabel.text = "\(weather.temprature)°C"
		weatherConditionLabel.text = weather.condition.rawValue
		pressureLabel.text = weather.pressure + "IN"
		humidityLabel.text = weather.humidity + "%"
		visibilityLabel.text = weather.visibility + "M"
		sunriseLabel.text = String(format: "%02d:%02d", weather.sunriseTime.hour, weather.sunriseTime.minute)
		sunsetLabel.text = String(format: "%02d:%02d", weather.sunsetTime.hour, weather.sunsetTime.minute)
		conditionIcon.image = weather.condition.icon
		pressureTrendLabel.text = weather.pressureTrend
		
		windsTempLabel.text = "Winds Temperature: \(weather.windTemperatue)°C"
		windsDirectionLabel.text = "Winds Direction: " + weather.windsDirection
		windsSpeedLabel.text = "Winds Speed: \(weather.windsSpeed)m/h"
	}
	
	// MARK: - Weather and location
	
	func refreshWeather() {
		let city = CityManager.sharedManager.currentCity
		let weatherDidRefresh: (Weather?, ErrorType?) -> Void = { [weak self] in
			self?.syncButton.layer.removeAllAnimations()
			if $1 != nil || $0 == nil {
				self?.syncButton.setImage(UIImage(named: "errorsync")!, forState: .Normal)
			} else {
				self?.currentWeather = $0!
			}
		}
		if CityManager.sharedManager.currentCity != nil {
			WeatherStation.sharedStation.all(for: city!, completion: weatherDidRefresh)
		} else {
			WeatherStation.sharedStation.all(weatherDidRefresh)
		}
	}
	
	func refreshLocation() {
		WeatherStation.sharedStation.locationStorage.refreshLocation()
	}
	
	// MARK: - Outlet actions
	
	@IBAction func syncButtonPressedUp(sender: UIButton) {
		syncButton.setImage(UIImage(named: "sync")!, forState: .Normal)
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.duration = 2
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeForwards
		animation.fromValue = 2 * M_PI
		animation.toValue = 0
		animation.repeatCount = 5
		sender.layer.addAnimation(animation, forKey: "rotation")
		let city = CityManager.sharedManager.currentCity
		if city == nil {
			refreshLocation()
		} else {
			refreshWeather()
		}
	}
	
	@IBAction func addButtonPressed(sender: UIButton) {
		performSegueWithIdentifier(Common.segueCitySearch, sender: nil)
	}
	
	@IBAction func touchToFullScreen() {
		guard animating == false else { return }
		animating = true
		let generator = AnimationGenerator()
		let moveAnimation = generator.moveAnimation(axis: .y, duration: 0.3, fillMode: kCAFillModeForwards)
		let opacityAnimation = generator.opacityAnimation(duration: moveAnimation.duration)
		let tabAnimation = generator.moveAnimation(axis: .y, duration: moveAnimation.duration, fillMode: kCAFillModeForwards)
		let hideClosure: () -> ()
		
		if infoPanel.hidden == false {
			(moveAnimation.fromValue, moveAnimation.toValue) = (infoPanel.center.y, view.bounds.height + 150)
			(tabAnimation.fromValue, tabAnimation.toValue) = (tabBarController?.tabBar.center.y, moveAnimation.toValue)
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (0, 1)
			hideClosure = { [weak self] in
				self?.infoPanel.hidden = true
				self?.tabBarController?.tabBar.alpha = 0
			}
		} else {
			infoPanel.hidden = false
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (1, 0)
			(moveAnimation.fromValue, moveAnimation.toValue) = (view.bounds.height + 150, infoPanel.center.y)
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (moveAnimation.fromValue, tabBarController?.tabBar.center.y)
			hideClosure = { [weak self] in
				self?.tabBarController?.tabBar.alpha = 1
			}
		}
		
		infoPanel.layer.addAnimation(moveAnimation, forKey: nil)
		tabBarController?.tabBar.layer.addAnimation(tabAnimation, forKey: nil)
		windsSpeedLabel.layer.addAnimation(opacityAnimation, forKey: nil)
		windsDirectionLabel.layer.addAnimation(opacityAnimation, forKey: nil)
		windsTempLabel.layer.addAnimation(opacityAnimation, forKey: nil)
		Delay(moveAnimation.duration - 0.05) { [weak self] in
			hideClosure()
			self?.windsTempLabel.layer.opacity = 1 - (self?.windsTempLabel.layer.opacity ?? 0)
			self?.windsDirectionLabel.layer.opacity = 1 - (self?.windsDirectionLabel.layer.opacity ?? 0)
			self?.windsSpeedLabel.layer.opacity = 1 - (self?.windsSpeedLabel.layer.opacity ?? 0)
			self?.animating = false
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
		guard let identifier = segue.identifier else { return }
		let city = CityManager.sharedManager.currentCity ?? WeatherStation.sharedStation.cachedCity
		if identifier == Common.unwindBackMain && city != nil {
			let weather = WeatherStation.sharedStation.cachedWeather[city!]
			currentWeather = weather
		}
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
	
	// MARK: - App out and in
	func enterForeground() {
		player?.play()
		syncButtonPressedUp(syncButton)
	}
}

extension ViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
}