//
//  ViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    
    @IBOutlet weak var btnStart: UIImageView!
    @IBOutlet weak var btnSettings: UIImageView!

    @IBOutlet weak var selectorTeam1: TeamSelector!
    @IBOutlet weak var selectorTeam2: TeamSelector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBtns()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBtns() {
        let tapStartGesture = UITapGestureRecognizer(target: self, action: #selector(self.startTapped))
        btnStart.addGestureRecognizer(tapStartGesture)
        
        let tapSettingsGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingsTapped))
        btnSettings.addGestureRecognizer(tapSettingsGesture)
    }

    func startTapped() {
        print("start tapped")
        performSegue(withIdentifier: "toSimulationSegue", sender: self)
    }
    
    func settingsTapped() {
        print("settings tapped")
        performSegue(withIdentifier: "toSettingsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSimulationSegue" {
            let target = segue.destination as! SimulationViewController
            target.team1 = selectorTeam1.selectedTeam
            target.team2 = selectorTeam2.selectedTeam
        } else if segue.identifier == "toSettingsSegue" {
            print("prepare for toSettingsSegue")
        }
    }
}

