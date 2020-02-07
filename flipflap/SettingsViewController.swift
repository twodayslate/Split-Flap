//
//  SettingsViewController.swift
//  flipflap
//
//  Created by Zachary Gorak on 2/7/20.
//  Copyright © 2020 twodayslate. All rights reserved.
//

import Foundation
import UIKit

class SettingsNavigationController: UINavigationController {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [SettingsViewController()]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close(_:)))
    }
    
    @objc func close(_ sender: Any?) {
        self.dismiss(animated: true, completion: {
            (self.parent as? ViewController)?.flaps.reload()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self.navigationController, action: #selector(SettingsNavigationController.close(_:)))
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func showSeconds(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showSeconds")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let secSwitch = UISwitch()
        cell.textLabel?.text = "Show seconds"
        secSwitch.setOn(UserDefaults.standard.bool(forKey: "showSeconds"), animated: false)
        secSwitch.addTarget(self, action: #selector(showSeconds(_:)), for: .valueChanged)
        cell.accessoryView = secSwitch
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
