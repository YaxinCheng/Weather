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
	
	@IBOutlet weak var mainUnitLabel: UILabel!

	var currentWeather: Weather! {
		didSet {
			guard let weather = currentWeather else { return }
			setupLabels(weather)
			setupPlayer(weather.condition)
		}
	}
	
	var backgroundView: UIImageView!
	fileprivate var animating = false
	
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
		
		NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshWeather), name: NSNotification.Name(rawValue: CityManagerNotification.currentCityDidChange.rawValue), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshWeather), name: NSNotification.Name(rawValue: LocationStorageNotification.locationUpdated.rawValue), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshWeather), name: NSNotification.Name(rawValue: LocationStorageNotification.noNewLocation.rawValue), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		cityButton.titleLabel?.numberOfLines = 1
		cityButton.titleLabel?.adjustsFontSizeToFitWidth = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshWeather()
		UIApplication.shared.statusBarStyle = .lightContent
	}
	
	override func viewWillDisappear(_ animated: Bool) {
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
		player?.seek(to: kCMTimeZero)
		player?.play()
	}
	
	func setupPlayer(_ weather: WeatherCondition) {
		let name = UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? weather.videoName : weather.landscapeVideoName
		guard let videoURL = Bundle.main.url(forResource: name, withExtension: "mp4") else { return }
		if player == nil {
			player = AVPlayer(url: videoURL)
			player?.actionAtItemEnd = .none
			player?.isMuted = true
		} else {
			player?.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
		}
		let playerLayer = AVPlayerLayer(player: player)
		self.playerLayer = playerLayer
		playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		playerLayer.zPosition = -1
		playerLayer.frame = backgroundView?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
		backgroundView.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	func setupLabels(_ weather: Weather) {
		if backgroundView != nil {
			backgroundView.removeFromSuperview()
		}
		
		let name = UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? weather.condition.videoName : weather.condition.landscapeVideoName
		backgroundView = UIImageView(image: UIImage(named: name)!)
		if UI_USER_INTERFACE_IDIOM() == .phone {
			backgroundView.frame = UIScreen.main.bounds
		} else if UI_USER_INTERFACE_IDIOM() == .pad {
			let screenFrame = (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
			let width = max(screenFrame.0, screenFrame.1)
			let height = screenFrame.0 == width ? screenFrame.1 : screenFrame.0
			let frame = UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? CGRect(x: 0, y: 0, width: height, height: width) : CGRect(x: 0, y: 0, width: width, height: height)
			backgroundView.frame = frame
		}
		
		backgroundView.contentMode = .scaleToFill
		view.insertSubview(backgroundView, at: 0)
		
		if let city = CityManager.sharedManager.currentCity {
			cityButton.setTitle(city.name, for: UIControlState())
		} else {
			let name = "Local"
			cityButton.setTitle(name, for: UIControlState())
		}
		mainUnitLabel.text = "\(WeatherStation.sharedStation.temperatureUnit)"
		tempLabel.text = "\(weather.temprature)"
		weatherConditionLabel.text = weather.condition.rawValue
		pressureLabel.text = weather.pressure + "IN"
		humidityLabel.text = weather.humidity + "%"
		visibilityLabel.text = "\(weather.visibility)\(WeatherStation.sharedStation.distanceUnit)"
		sunriseLabel.text = String(format: "%02d:%02d", weather.sunriseTime.hour!, weather.sunriseTime.minute!)
		sunsetLabel.text = String(format: "%02d:%02d", weather.sunsetTime.hour!, weather.sunsetTime.minute!)
		conditionIcon.image = weather.condition.icon
		pressureTrendLabel.text = weather.pressureTrend
		
		windsTempLabel.text = "WINDS TEMPERATURE: \(weather.windTemperatue)\(WeatherStation.sharedStation.temperatureUnit)"
		windsDirectionLabel.text = "WINDS DIRECTION: " + weather.windsDirection
		windsSpeedLabel.text = "WINDS SPEED: \(weather.windsSpeed)\(WeatherStation.sharedStation.speedUnit)"
	}
	
	// MARK: - Weather and location
	
	func refreshWeather() {
		let city = CityManager.sharedManager.currentCity
		let weatherDidRefresh: (Weather?, Error?) -> Void = { [weak self] in
			self?.syncButton.layer.removeAllAnimations()
			if $1 != nil || $0 == nil {
				self?.syncButton.setImage(UIImage(named: "errorsync")!, for: UIControlState())
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
	
	@IBAction func syncButtonPressedUp(_ sender: UIButton) {
		syncButton.setImage(UIImage(named: "sync")!, for: UIControlState())
		let generator = AnimationGenerator()
		let animation = generator.rotationAnimation(axis: .z, duration: 2, removeOnCompletion: false, fillMode: kCAFillModeForwards, from: 2 * M_PI, to: 0, repeatCount: 5)
		sender.layer.add(animation, forKey: "rotation")
		let local = CityManager.sharedManager.isLocal
		if local {
			refreshLocation()
			CityManager.sharedManager.currentCity = nil
		} else {
			refreshWeather()
		}
	}
	
	@IBAction func addButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: Common.segueCitySearch, sender: nil)
	}
	
	@IBAction func touchToFullScreen() {
		guard animating == false else { return }
		animating = true
		let generator = AnimationGenerator()
		let moveAnimation = generator.moveAnimation(axis: .y, duration: 0.3, fillMode: kCAFillModeForwards)
		let opacityAnimation = generator.opacityAnimation(duration: moveAnimation.duration)
		let tabAnimation = generator.moveAnimation(axis: .y, duration: moveAnimation.duration, fillMode: kCAFillModeForwards)
		let hideClosure: () -> ()
		
		if infoPanel.isHidden == false {
			(moveAnimation.fromValue, moveAnimation.toValue) = (infoPanel.center.y, view.bounds.height + 150)
			(tabAnimation.fromValue, tabAnimation.toValue) = (tabBarController?.tabBar.center.y, moveAnimation.toValue)
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (0, 1)
			hideClosure = { [weak self] in
				self?.infoPanel.isHidden = true
				self?.tabBarController?.tabBar.alpha = 0
			}
		} else {
			infoPanel.isHidden = false
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (1, 0)
			(moveAnimation.fromValue, moveAnimation.toValue) = (view.bounds.height + 150, infoPanel.center.y)
			(opacityAnimation.fromValue, opacityAnimation.toValue) = (moveAnimation.fromValue, tabBarController?.tabBar.center.y)
			hideClosure = { [weak self] in
				self?.tabBarController?.tabBar.alpha = 1
			}
		}
		
		infoPanel.layer.add(moveAnimation, forKey: nil)
		tabBarController?.tabBar.layer.add(tabAnimation, forKey: nil)
		windsSpeedLabel.layer.add(opacityAnimation, forKey: nil)
		windsDirectionLabel.layer.add(opacityAnimation, forKey: nil)
		windsTempLabel.layer.add(opacityAnimation, forKey: nil)
		Delay(moveAnimation.duration - 0.05) { [weak self] in
			hideClosure()
			self?.windsTempLabel.layer.opacity = 1 - (self?.windsTempLabel.layer.opacity ?? 0)
			self?.windsDirectionLabel.layer.opacity = 1 - (self?.windsDirectionLabel.layer.opacity ?? 0)
			self?.windsSpeedLabel.layer.opacity = 1 - (self?.windsSpeedLabel.layer.opacity ?? 0)
			self?.animating = false
		}
	}
	
	@IBAction func cityButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: Common.segueCityView, sender: nil)
	}
	
	@IBAction func cityButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
		performSegue(withIdentifier: Common.segueCitySearch, sender: nil)
	}
	
	@IBAction func swipeDownPanel(_ sender: UISwipeGestureRecognizer) {
		touchToFullScreen()
	}
	
	// MARK: - Navigation
	@IBAction func prepareForUnwindSegue(_ segue: UIStoryboardSegue) {
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier else { return }
		if identifier == Common.segueCityView {
			let destinationVC = segue.destination as! CityListViewController
			destinationVC.modalPresentationStyle = .popover
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
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}
