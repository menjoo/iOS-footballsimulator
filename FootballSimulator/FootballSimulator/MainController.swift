//
//  ViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit
import AVFoundation

class MainController: UIViewController {
    
    @IBOutlet weak var sierd: UIImageView!
    let sierdSounds = ["_call_by_mom", "_copa_cabana", "_goal_0",  "_goal_1", "_goal_2", "_goal_3", "_miss_0", "_yellow_card", "_zwaluw"]
    var currentSierd: Int = 0
    
    @IBOutlet weak var btnStart: UIImageView!
    @IBOutlet weak var btnSettings: UIImageView!

    @IBOutlet weak var selectorTeam1: TeamSelector!
    @IBOutlet weak var selectorTeam2: TeamSelector!
    
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Match"
        setupBtns()
        currentSierd = Int(arc4random()) % sierdSounds.count - 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBtns() {
        let tapSierdGesture = UITapGestureRecognizer(target: self, action: #selector(self.sierdTapped))
        sierd.addGestureRecognizer(tapSierdGesture)
        
        let tapStartGesture = UITapGestureRecognizer(target: self, action: #selector(self.startTapped))
        btnStart.addGestureRecognizer(tapStartGesture)
        
        let tapSettingsGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingsTapped))
        btnSettings.addGestureRecognizer(tapSettingsGesture)
    }
    
    func sierdTapped() {
        print("sierd tapped")
        playSound(sierdSounds[currentSierd])
        currentSierd += 1
        
        if currentSierd > sierdSounds.count - 1 {
            currentSierd = 0
        }
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
    
    func playSound(_ sound: String) {
        let url = Bundle.main.url(forResource: sound, withExtension: "mp3")!
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            guard let soundPlayer = soundPlayer else { return }
            soundPlayer.prepareToPlay()
            soundPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

