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
    var shouldSetTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .systemBackground
        
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
        
        innerView.addSubview(settingsButton)
        settingsButton.bottomAnchor.constraint(equalTo: innerView.bottomAnchor, constant: -16.0).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -16.0).isActive = true
        //settings.heightAnchor.constraint(equalToConstant: 24).isActive = true
        settingsButton.widthAnchor.constraint(equalTo: settingsButton.heightAnchor).isActive = true
        settingsButton.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        
        let tapScreenGesture = UITapGestureRecognizer(target: self, action: #selector(tapScreen(_:)))
        self.view.addGestureRecognizer(tapScreenGesture)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .common)
    }
    
    @objc func tapScreen(_ sender: UITapGestureRecognizer) {
        print("did tap")
        self.settingsButton.isHidden = false
        UIView.animate(withDuration: 1.0, animations: {
            self.settingsButton.alpha = 0.9
        })
    }
    
    @objc func openSettings(_ sender: UIButton) {
        self.present(SettingsNavigationController(), animated: true, completion: nil)
    }
    
    @objc
    func updateTimer(timer: Timer) {
        if shouldSetTime {
            DispatchQueue.main.async {
                
                if Calendar.current.is24Hour {
                    if UserDefaults.standard.bool(forKey: "showSeconds") {
                        self.flapText = Date().convertToLocaleDate(template: "HH:mm:ss")
                    } else {
                        self.flapText = Date().convertToLocaleDate(template: "HH:mm")
                    }
                } else {
                    if UserDefaults.standard.bool(forKey: "showSeconds") {
                        self.flapText = Date().convertToLocaleDate(template: "h:mm:ss a")
                    } else {
                        self.flapText = Date().convertToLocaleDate(template: "h:mm a")
                    }
                    
                }

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
      return FlapViewBuilder { builder in
        builder.backgroundColor = .secondarySystemBackground
        builder.textColor       = .label
        builder.lineColor       = .opaqueSeparator
      }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.settingsButton.alpha = 0.9
        })
        self.flaps.setText(self.flapText, animated: animated, completionBlock: {
            self.shouldSetTime = true
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

