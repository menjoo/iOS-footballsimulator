//
//  SettingsViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    let values: [SimulationMode] = [.realTime, .normal, .slow, .quick, .veryQuick]
    var currentIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speedSlider.isContinuous = true
        speedSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        speedSlider.maximumValue = Float(values.count - 1)
        speedSlider.minimumValue = 0
        
        let gameSpeed = UserDefaults.standard.integer(forKey: "gameSpeed")
        currentIndex = gameSpeed
        speedSlider.setValue(Float(values[currentIndex].rawValue), animated: false)
        
        speedLabel.text = "\(values[currentIndex])".capitalized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sliderValueChanged(sender: AnyObject) {
        let index = Int(speedSlider.value + 0.5)
        speedSlider.setValue(Float(index), animated: false)
        currentIndex = values[index].rawValue
        
        speedLabel.text = "\(values[currentIndex])".capitalized
    }
    
    @IBAction func doneAction(_ sender: Any) {
        save(gameSpeed: values[currentIndex].rawValue)
        dismiss(animated: true, completion: nil)
    }
    
    func save(gameSpeed: Int) {
        UserDefaults.standard.set(gameSpeed, forKey: "gameSpeed")
    }
}
