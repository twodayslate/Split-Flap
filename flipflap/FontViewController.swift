//
//  FontViewController.swift
//  flipflap
//
//  Created by Zachary Gorak on 2/12/20.
//  Copyright © 2020 twodayslate. All rights reserved.
//

import Foundation
import UIKit

protocol FontControllerDelegate {
    var currentlySelectedFont: String? { get }
    func didChangeFont(name: String)
}

class FontNavigationController: UINavigationController, FontControllerDelegate {
    var fontDelegate: FontControllerDelegate? = nil
    func didChangeFont(name: String) {
        self.fontDelegate?.didChangeFont(name: name)
    }
    
    var currentlySelectedFont: String? = nil {
        didSet {
            self.settings.currentlySelectedFont = self.currentlySelectedFont
            self.settings.tableView.reloadData()
        }
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    let settings = FontTableViewController(style: .plain)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        self.settings.fontDelegate = self
        self.viewControllers = [settings]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
    
    @objc func close(_ sender: Any?) {
        self.dismiss(animated: true, completion: {})
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FontTableViewController: UITableViewController, FontControllerDelegate {
    var fontDelegate: FontControllerDelegate? = nil
    func didChangeFont(name: String) {
        self.fontDelegate?.didChangeFont(name: name)
    }
    
    var currentlySelectedFont: String? {
        didSet {
            self.tableView.reloadData()
            if let name = self.currentlySelectedFont {
                self.didChangeFont(name: name)
            }
            
        }
    }
    
    let familyNames = UIFont.familyNames.sorted()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.view.backgroundColor = .systemBackground
        self.tableView.backgroundColor = .systemGroupedBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self.navigationController, action: #selector(FontNavigationController.close(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(reset(_:)))
    }
    
    @objc func reset(_ sender: Any?) {
        let font = UIFont(name: "Courier", size: 45.0)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "font")
                
        self.currentlySelectedFont = font?.familyName
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.familyNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "font")
        let fontName = self.familyNames[indexPath.row]
        cell.textLabel?.text = fontName
        cell.textLabel?.font = UIFont(name: fontName, size: cell.textLabel?.font.pointSize ?? 14.0)
        
        if self.currentlySelectedFont == cell.textLabel?.font.familyName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fontName = self.familyNames[indexPath.row]
        
        let font = UIFont(name: fontName, size: 45.0)
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "font")
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.currentlySelectedFont = font?.familyName
    }
}
