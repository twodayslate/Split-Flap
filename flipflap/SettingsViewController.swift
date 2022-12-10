//
//  SettingsViewController.swift
//  flipflap
//
//  Created by Zachary Gorak on 2/7/20.
//  Copyright © 2020 twodayslate. All rights reserved.
//

import Foundation
import UIKit
import EFColorPicker

protocol SettingsControllerDelegate {
    func willCloseSettings()
    func didCloseSettings()
    func didChangeKey(_ key: String)
}

class SettingsNavigationController: UINavigationController {
    var settingsDelegate: SettingsControllerDelegate? = nil {
        didSet {
            settings.settingsDelegate = self.settingsDelegate
        }
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    let settings = SettingsViewController(style: .insetGrouped)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = [settings]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
    
    @objc func close(_ sender: Any?) {
        self.settingsDelegate?.willCloseSettings()
        self.dismiss(animated: true, completion: {
            self.settingsDelegate?.didCloseSettings()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsViewController: UITableViewController {
    var settingsDelegate: SettingsControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.view.backgroundColor = .systemBackground
        self.tableView.backgroundColor = .systemGroupedBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self.navigationController, action: #selector(SettingsNavigationController.close(_:)))
    }
    
    let themeSheet = UIAlertController(title: "Theme", message: nil, preferredStyle: .actionSheet)
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Appearance"
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    @objc func showSeconds(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showSeconds")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        switch indexPath.section {
        case 0:
            cell = UITableViewCell(style: .value1, reuseIdentifier: "value1")
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Theme"
                
                switch UserDefaults.standard.integer(forKey: "theme") {
                case 1:
                    cell.detailTextLabel?.text = "Light"
                case 2:
                    cell.detailTextLabel?.text = "Dark"
                case 3:
                    cell.detailTextLabel?.text = "Custom"
                default:
                    cell.detailTextLabel?.text = "System"
                }
                break
            case 1:
                if UserDefaults.standard.integer(forKey: "theme") == 3 {
                    cell.textLabel?.text = "Background Color"
                    var color = UIColor.systemBackground
                    
                    //colorView.backgroundColor = .red
                    if let data = UserDefaults.standard.object(forKey: "background_color") as? Data, let dcolor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {

                        color = dcolor
                    }
                    
                    let size = CGSize(width: 24.0, height: 24.0)
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let image = renderer.image(actions: { rendererContext in
                        color.setFill()
                        rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    })
                    cell.imageView?.image = image
                    cell.imageView?.layer.cornerRadius = 5.0
                    cell.imageView?.layer.borderColor = UIColor.opaqueSeparator.cgColor
                    cell.imageView?.layer.borderWidth = 1.0
                    cell.imageView?.clipsToBounds = true
                    
                } else {
                    cell.textLabel?.text = "Font"
                    cell.accessoryType = .disclosureIndicator
                    if let data = UserDefaults.standard.object(forKey: "font") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIFont.self], from: data) as? UIFont {

                        cell.detailTextLabel?.text = color.familyName
                    } else {
                        cell.detailTextLabel?.text = "Courier"
                    }
                }
            case 2:
                if UserDefaults.standard.integer(forKey: "theme") == 3 {
                    cell.textLabel?.text = "Flap Color"
                    var color = UIColor.secondarySystemBackground
                    
                    //colorView.backgroundColor = .red
                    if let data = UserDefaults.standard.object(forKey: "flap_color") as? Data, let dcolor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {

                        color = dcolor
                    }
                    
                    let size = CGSize(width: 24.0, height: 24.0)
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let image = renderer.image(actions: { rendererContext in
                        color.setFill()
                        rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    })
                    cell.imageView?.image = image
                    cell.imageView?.layer.cornerRadius = 5.0
                    cell.imageView?.layer.borderColor = UIColor.opaqueSeparator.cgColor
                    cell.imageView?.layer.borderWidth = 1.0
                    cell.imageView?.clipsToBounds = true
                } else {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "reset")
                    cell.accessoryType = .none
                    cell.textLabel?.text = "Reset to Default"
                    cell.textLabel?.textColor = tableView.tintColor
                    cell.textLabel?.textAlignment = .center
                }
                
            case 3:
                cell.textLabel?.text = "Text Color"
                var color = UIColor.label
                
                //colorView.backgroundColor = .red
                if let data = UserDefaults.standard.object(forKey: "text_color") as? Data, let dcolor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {

                    color = dcolor
                }
                
                let size = CGSize(width: 24.0, height: 24.0)
                let renderer = UIGraphicsImageRenderer(size: size)
                let image = renderer.image(actions: { rendererContext in
                    color.setFill()
                    rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                })
                cell.imageView?.image = image
                cell.imageView?.layer.cornerRadius = 5.0
                cell.imageView?.layer.borderColor = UIColor.opaqueSeparator.cgColor
                cell.imageView?.layer.borderWidth = 1.0
                cell.imageView?.clipsToBounds = true
            case 4:
                cell.textLabel?.text = "Font"
                cell.accessoryType = .disclosureIndicator
                if let data = UserDefaults.standard.object(forKey: "font") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIFont.self], from: data) as? UIFont {

                    cell.detailTextLabel?.text = color.familyName
                } else {
                    cell.detailTextLabel?.text = "Courier"
                }
            case 5:
                cell.textLabel?.text = "Reset to Default"
                cell.accessoryType = .none
                cell.textLabel?.textColor = tableView.tintColor
                cell.textLabel?.textAlignment = .center
            default:
                break
            }
            
            break
        case 1:
            let secSwitch = UISwitch()
            cell.textLabel?.text = "Show seconds"
            secSwitch.setOn(UserDefaults.standard.bool(forKey: "showSeconds"), animated: false)
            secSwitch.addTarget(self, action: #selector(showSeconds(_:)), for: .valueChanged)
            cell.accessoryView = secSwitch
            cell.selectionStyle = .none
        default:
            break
        }
        
        return cell
    }
    
    var currentColorPicker: EFColorSelectionViewController? = nil
    var currentColorPickerKey: String? = nil
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if themeSheet.actions.count == 0 {
                    let inappSafariAction = UIAlertAction(title: "System", style: .default, handler: { _ in
                        print("Auto")
                        UserDefaults.standard.set(0, forKey: "theme")
                        UserDefaults.standard.synchronize()
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.detailTextLabel?.text = "System"
                        self.clearCustomColors()
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        
                    })
                    themeSheet.addAction(inappSafariAction)
                    if #available(iOS 13.0, *) {
                        let safariAction = UIAlertAction(title: "Light", style: .default, handler: { _ in
                            print("Auto")
                            UserDefaults.standard.set(1, forKey: "theme")
                            UserDefaults.standard.synchronize()
                            let cell = self.tableView.cellForRow(at: indexPath)
                            cell?.detailTextLabel?.text = "Light"
                            self.clearCustomColors()
                            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        })
                        themeSheet.addAction(safariAction)
                        let darkAction = UIAlertAction(title: "Dark", style: .default, handler: { _ in
                            print("Dark")
                            UserDefaults.standard.set(2, forKey: "theme")
                            UserDefaults.standard.synchronize()
                            let cell = self.tableView.cellForRow(at: indexPath)
                            cell?.detailTextLabel?.text = "Dark"
                            self.clearCustomColors()
                            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        })
                        themeSheet.addAction(darkAction)
                        let customAction = UIAlertAction(title: "Custom", style: .default, handler: { _ in
                            UserDefaults.standard.set(3, forKey: "theme")
                            UserDefaults.standard.synchronize()
                            let cell = self.tableView.cellForRow(at: indexPath)
                            cell?.detailTextLabel?.text = "Custom"
                            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        })
                        themeSheet.addAction(customAction)
                    }
                    themeSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                }

                for (index, action) in themeSheet.actions.enumerated() {
                    if UserDefaults.standard.integer(forKey: "theme") == index {
                        action.setValue("true", forKey: "checked")
                    } else {
                        action.setValue("false", forKey: "checked")
                    }
                }
                // swiftlint:disable:next line_length
                self.addActionSheetForiPad(actionSheet: themeSheet)
                present(themeSheet, animated: true) {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case 4:
                print("selected 4")
                let c = FontNavigationController()
                c.fontDelegate = self
                c.currentlySelectedFont = self.currentlySelectedFont
                self.present(c, animated: true, completion: {
                    tableView.deselectRow(at: indexPath, animated: true)
                })
                break
            case 5:
                print("selected 5")
                tableView.deselectRow(at: indexPath, animated: true)
                self.resetToDefault()
                break
            default:
                if UserDefaults.standard.integer(forKey: "theme") == 3 {

                    let colorSelectionController = EFColorSelectionViewController()
                    colorSelectionController.isColorTextFieldHidden = false
                    let navCtrl = UINavigationController(rootViewController: colorSelectionController)
                    navCtrl.navigationBar.backgroundColor = UIColor.systemBackground
                    navCtrl.navigationBar.isTranslucent = false
                    navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover

                    navCtrl.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                    navCtrl.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)!.bounds
                    navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
                        UIView.layoutFittingCompressedSize
                    )
                    if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
                        
                        colorSelectionController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissColorPicker(_:)))
                        
                        colorSelectionController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(resetsColorPicker(_:)))
                    }

                    //colorSelectionController.delegate = self
                    
                    colorSelectionController.setMode(mode: .all)
                    self.currentColorPicker = colorSelectionController
                    
                    switch indexPath.row {
                        case 1:
                            self.currentColorPickerKey = "background_color"
                            if let data = UserDefaults.standard.object(forKey: "background_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                                
                                colorSelectionController.color = color
                            } else {
                                colorSelectionController.color = .systemBackground
                            }
                            break
                    case 2:
                        self.currentColorPickerKey = "flap_color"
                        if let data = UserDefaults.standard.object(forKey: "flap_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                            
                            colorSelectionController.color = color
                        } else {
                            colorSelectionController.color = .secondarySystemBackground
                        }
                        break
                    case 3:
                        self.currentColorPickerKey = "text_color"
                        if let data = UserDefaults.standard.object(forKey: "text_color") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                            
                            colorSelectionController.color = color
                        } else {
                            colorSelectionController.color = .label
                        }
                        break
                        
                    default:
                        break
                    }
                    
                    present(navCtrl, animated: true) {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                } else {
                    switch indexPath.row {
                    case 1:
                        let c = FontNavigationController()
                        c.fontDelegate = self
                        c.currentlySelectedFont = self.currentlySelectedFont
                        self.present(c, animated: true, completion: {
                            tableView.deselectRow(at: indexPath, animated: true)
                        })
                    case 2:
                        tableView.deselectRow(at: indexPath, animated: true)
                        self.resetToDefault()
                    default:
                        break
                    }
                }
                break
            }
            break
        default:
            break
        }
    }
    
    @objc func dismissColorPicker(_ sender: UIBarButtonItem?) {
        print(self.currentColorPicker?.color)
        guard let color = self.currentColorPicker?.color, let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false), let key = currentColorPickerKey else {
            return
        }
        UserDefaults.standard.set(data, forKey: key)
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        self.currentColorPicker?.dismiss(animated: true, completion: nil)
    }
    
    func resetToDefault() {
        UserDefaults.standard.set(0, forKey: "theme")
        self.clearCustomColors()
        let font = UIFont(name: "Courier", size: 45.0)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "font")
        }
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func clearCustomColors() {
        UserDefaults.standard.removeObject(forKey: "background_color")
        UserDefaults.standard.removeObject(forKey: "text_color")
        UserDefaults.standard.removeObject(forKey: "flap_color")
        self.settingsDelegate?.didChangeKey("background_color")
        self.settingsDelegate?.didChangeKey("text_color")
        self.settingsDelegate?.didChangeKey("flap_color")
    }
    
    @objc func resetsColorPicker(_ sender: UIBarButtonItem?) {
        guard let key = currentColorPickerKey else {
            return
        }
        
        var color = UIColor.systemBackground
        if key == "text_color" {
            color = .label
        } else if key == "flap_color" {
            color = .secondarySystemBackground
        }
        self.currentColorPicker?.color = color
        
        self.dismissColorPicker(sender)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if UserDefaults.standard.integer(forKey: "theme") == 3 {
                return 6
            }
            return 3
        default:
            return 1
        }
    }
}

extension SettingsViewController: FontControllerDelegate {
    var currentlySelectedFont: String? {
        if let data = UserDefaults.standard.object(forKey: "font") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIFont.self], from: data) as? UIFont {

            return color.familyName
        } else {
            return "Courier"
        }
    }
    
    func didChangeFont(name: String) {
        self.tableView.reloadData()
    }
    
    
}
