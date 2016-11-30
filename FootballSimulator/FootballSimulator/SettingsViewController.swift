//
//  SettingsViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func save(gameSpeed: Int) {
        UserDefaults.standard.set(gameSpeed, forKey: "gameSpeed")
    }
}
