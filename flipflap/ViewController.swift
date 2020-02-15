//
//  ViewController.swift
//  flipflap
//
//  Created by Zachary Gorak on 2/7/20.
//  Copyright © 2020 twodayslate. All rights reserved.
//

import UIKit
import Splitflap

extension Date {
    func convertToLocaleDate(template: String) -> String {
        let dateFormatter = DateFormatter()

        let calender = Calendar.current

        dateFormatter.timeZone = calender.timeZone
        dateFormatter.locale = calender.locale
        dateFormatter.setLocalizedDateFormatFromTemplate(template)

        return dateFormatter.string(from: self)
    }
}

extension Calendar {
    var is24Hour: Bool {
        guard let locale = self.locale else {
            return false
        }
        guard let c = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) else {
            return false
        }
        // "h a" when not 24 hours
        return !c.contains("a")
    }
}

class ViewController: UIViewController, SplitflapDataSource, SplitflapDelegate {
    
    var flaps = Splitflap()
    private var previousFlapText: String?
    var flapText = "Hello" {
        willSet {
            self.previousFlapText = self.flapText
        }
        didSet {
            guard let previousFlapText = self.previousFlapText else {
                return
            }
            if previousFlapText.count != self.flapText.count {
                self.flaps.reload()
            }
        }
    }
    let settingsButton = UIButton(type: .system)
    var timer = Timer()
    var shouldSetTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .systemBackground
        if let data = UserDefaults.standard.object(forKey: "background_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            
            self.view.backgroundColor = color
        }
        
        self.flaps.delegate = self
        self.flaps.datasource = self
        self.flaps.translatesAutoresizingMaskIntoConstraints = false
        
        let innerView = UIView()
        innerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(innerView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": innerView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": innerView]))
        
        innerView.addSubview(self.flaps)
        
        self.flaps.centerXAnchor.constraint(equalTo: innerView.centerXAnchor).isActive = true
        self.flaps.centerYAnchor.constraint(equalTo: innerView.centerYAnchor).isActive = true
        
        self.flaps.widthAnchor.constraint(equalTo: innerView.widthAnchor).isActive = true
        //self.flaps.heightAnchor.constraint(lessThanOrEqualTo: innerView.heightAnchor).isActive = true
        self.flaps.heightAnchor.constraint(equalTo: self.flaps.widthAnchor, multiplier: 0.5).isActive = true
        self.flaps.heightAnchor.constraint(lessThanOrEqualTo: innerView.heightAnchor, multiplier: 0.5).isActive = true
        
        
        settingsButton.setImage(UIImage.init(systemName: "gear"), for: .normal)
        settingsButton.alpha = 0.0
        settingsButton.tintColor = .systemFill
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.isUserInteractionEnabled = true
        settingsButton.isEnabled = true
        
        innerView.addSubview(settingsButton)
        settingsButton.bottomAnchor.constraint(equalTo: innerView.bottomAnchor, constant: -16.0).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -16.0).isActive = true
        //settings.heightAnchor.constraint(equalToConstant: 24).isActive = true
        settingsButton.widthAnchor.constraint(equalTo: settingsButton.heightAnchor).isActive = true
        settingsButton.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(tapScreen(_:)))
        tapScreenGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapScreenGesture)
        
        self.flapText = self.currentTime()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .common)
        
        UserDefaults.standard.addObserver(self, forKeyPath: "background_color", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "flap_color", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "text_color", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "font", options: .new, context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "background_color")
        UserDefaults.standard.removeObserver(self, forKeyPath: "flap_color")
        UserDefaults.standard.removeObserver(self, forKeyPath: "text_color")
        UserDefaults.standard.removeObserver(self, forKeyPath: "font")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else {
            return
        }
        self.didChangeKey(key)
    }
    
    @objc func tapScreen(_ sender: UITapGestureRecognizer) {
        print("did tap")
        self.showSettingsIcon()
    }
    
    @objc func showSettingsIcon() {
        print("showing icons")
        self.settingsButton.isEnabled = true
        self.settingsButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut], animations: {
            self.settingsButton.alpha = 1.0
        }, completion: { didComplete in
            self.hideSettingsIcon(didComplete, delay: 5.0)
        })
    }
    
    @objc func openSettings(_ sender: UIButton) {
        let settings = SettingsNavigationController()
        settings.settingsDelegate = self
        self.present(settings, animated: true, completion: nil)
    }
    
    func currentTime() -> String {
        if Calendar.current.is24Hour {
            if UserDefaults.standard.bool(forKey: "showSeconds") {
                return Date().convertToLocaleDate(template: "HH:mm:ss")
            } else {
                return Date().convertToLocaleDate(template: "HH:mm")
            }
        } else {
            if UserDefaults.standard.bool(forKey: "showSeconds") {
                return Date().convertToLocaleDate(template: "h:mm:ss a")
            } else {
                return Date().convertToLocaleDate(template: "h:mm a")
            }
        }
    }

    @objc
    func updateTimer(timer: Timer) {
        if shouldSetTime {
            DispatchQueue.main.async {
                
                self.flapText = self.currentTime()

                self.flaps.setText(self.flapText, animated: true)
            }
        }
    }
    
    func numberOfFlapsInSplitflap(_ splitflap: Splitflap) -> Int {
        return self.flapText.count
    }
    
    func tokensInSplitflap(_ splitflap: Splitflap) -> [String] {
        // so this is the order in which things will actually flip
        if shouldSetTime {
            if Calendar.current.is24Hour {
                return SplitflapTokens.Numeric + [":"]
            } else {
                let map = SplitflapTokens.Numeric + " AMP:".map { String($0) }
                return map
            }
        }
        let map =  SplitflapTokens.AlphanumericAndSpace + [":"]
        return map
    }
    
    func splitflap(_ splitflap: Splitflap, builderForFlapAtIndex index: Int) -> FlapViewBuilder {
        var background: UIColor = .secondarySystemBackground
        if let data = UserDefaults.standard.object(forKey: "flap_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            
            background = color
        }
        var textColor: UIColor = .label
        if let data = UserDefaults.standard.object(forKey: "text_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            
            textColor = color
        }
        
        var width = splitflap.bounds.width / CGFloat(self.numberOfFlapsInSplitflap(splitflap))

        var font = UIFont(name: "Courier", size: width)
        
        if let data = UserDefaults.standard.object(forKey: "font") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIFont.self], from: data) as? UIFont {

            font = UIFont(name: color.familyName, size: width)
        }
                
        return FlapViewBuilder { builder in
            builder.backgroundColor = background
            builder.textColor       = textColor
            builder.lineColor       = .opaqueSeparator
            builder.font = font
        }
    }
    
    func hideSettingsIcon(_ didComplete: Bool = true, delay: TimeInterval = 0.0) {
        print("did complete?", didComplete)
        if didComplete {
            UIView.animate(withDuration: 2.0, delay: delay, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.settingsButton.alpha = 0.011
            }, completion: { didComplete2 in
                print("did complete2:", didComplete2)
                if didComplete2 {
                    self.settingsButton.isUserInteractionEnabled = false
                    self.settingsButton.isEnabled = true
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.flaps.reload() // XXX remove once width fix is implemented
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.settingsButton.alpha = 1.0
        }, completion: { didComplete in
            self.hideSettingsIcon(didComplete, delay: 5.0)
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ViewController: SettingsControllerDelegate {
    func didChangeKey(_ key: String) {
        if key == "background_color" {
            if let data = UserDefaults.standard.object(forKey: key) as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                self.view.backgroundColor = color
            } else {
                self.view.backgroundColor = .systemBackground
            }
        }
        
        if key == "flap_color" || key == "text_color" || key == "font" {
            self.flaps.reload()
        }
    }
    
    func didCloseSettings() {
        self.showSettingsIcon()
    }
    
    func willCloseSettings() {
        self.showSettingsIcon()
        self.flaps.reload()
    }
}
