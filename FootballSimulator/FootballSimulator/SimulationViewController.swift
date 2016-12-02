//
//  SimulationViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit
import AVFoundation

class SimulationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GameEventSource, UIAlertViewDelegate {

    @IBOutlet weak var eventsTableView: UITableView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    @IBOutlet weak var flagIconTeam1: UIImageView!
    @IBOutlet weak var nameLabelTeam1: UILabel!
    
    @IBOutlet weak var flagIconTeam2: UIImageView!
    @IBOutlet weak var nameLabelTeam2: UILabel!
    
    public var team1: Team?
    public var team2: Team?
    var score: (goals1: Int, goals2: Int) = (goals1: 0,goals2: 0)
    
    var game: Game = Game()
    var events: [EventRow] = [EventRow]()
    var selectedIndex: Int = -1
    
    @IBOutlet weak var playPauseBtn: UIImageView!
    @IBOutlet weak var stopBtn: UIImageView!
    @IBOutlet weak var soundBtn: UIImageView!
    
    var shouldPlaySound: Bool = true
    var soundPlayerBg: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        self.eventsTableView.allowsSelection = true
        self.eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.game.delegate = self
        
        title = "Commentator: Sierd de Vos"
        
        scoreLabel.text = "0 - 0"
        statusLabel.text = "Not started"
        timeLabel.text = ""
        
        flagIconTeam1.image = team1?.flag
        nameLabelTeam1.text = team1?.fullname.uppercased()
        flagIconTeam2.image = team2?.flag
        nameLabelTeam2.text = team2?.fullname.uppercased()
        
        let gameSpeed = UserDefaults.standard.integer(forKey: "gameSpeed")
        
        game.startGame(team1!, teamb: team2!, gameMode: SimulationMode(rawValue: gameSpeed)!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MatchEventTableViewCell = eventsTableView.dequeueReusableCell(withIdentifier: "matchEventCell", for: indexPath) as! MatchEventTableViewCell
        
        cell.minuteLabel.text = ""
        cell.eventIconTeam1.image = nil
        cell.evenLabelTeam2.text = ""
        cell.eventIconTeam2.image = nil
        cell.eventLabelTeam1.text = ""
        cell.subtitleLabelTeam1.text = ""
        cell.subtitleLabelTeam2.text = ""
        
        cell.minuteLabel.text = "\(events[indexPath.row].time)'"
        
        let eventType = events[indexPath.row].gameEvent
        let event = events[indexPath.row]
        if("\(eventType)".contains("1")) {
            cell.eventIconTeam1.image = eventDataFor(event).eventIcon
            cell.eventLabelTeam1.text = eventDataFor(event).eventText
            cell.subtitleLabelTeam1.text = eventDataFor(event).subtitleText
        } else if("\(eventType)".contains("2")) {
            cell.eventIconTeam2.image = eventDataFor(event).eventIcon
            cell.evenLabelTeam2.text = eventDataFor(event).eventText
            cell.subtitleLabelTeam2.text = eventDataFor(event).subtitleText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        if selectedIndex == didSelectRowAt.row {
            selectedIndex = -1
        } else {
            selectedIndex = didSelectRowAt.row
        }
        
        eventsTableView.beginUpdates()
        eventsTableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedIndex {
            return 100.0
        } else {
            return 50.0
        }
    }
    
    func eventDataFor(_ event: EventRow) -> (eventIcon: UIImage?, eventText: String, subtitleText: String) {
        if event.gameEvent == .cornerGivenTeam1 || event.gameEvent == .corderGivenTeam2 {
            return (eventIcon: UIImage(named: "corner.png"),
                    eventText: "Corner",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) is taking the kick")
        } else if event.gameEvent == .goalScoredTeam1 || event.gameEvent == .goalScoredTeam2 {
            return (eventIcon: UIImage(named: "footbal.png"),
                    eventText: "Goaaaaalll!!!",
                    subtitleText: "Insane shot by \(playerNameFor(playerno: event.playerno, from: event.gameEvent)!)! A goal to remember!")
        } else if event.gameEvent == .playerInjuredTeam1 || event.gameEvent == .playerInjuredTeam2 {
            return (eventIcon: UIImage(named: "injury.png"),
                    eventText: "Injury",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) is in serious pain!")
        } else if event.gameEvent == .playerSwitchTeam1 || event.gameEvent == .playerSwitchTeam2 {
            return (eventIcon: UIImage(named: "sub.png"),
                    eventText: "Substitution",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) is being subbed")
        } else if event.gameEvent == .yellowCardTeam1 || event.gameEvent == .yellowCardTeam2 {
            return (eventIcon: UIImage(named: "card_yellow.png"),
                    eventText: "Yellow card",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) almost injured his opponent")
        } else if event.gameEvent == .redCardTeam1 || event.gameEvent == .redCardTeam2 {
            return (eventIcon: UIImage(named: "card_red.png"),
                    eventText: "Red card",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) is off!  Took down his opponent who was clearly in on goal")
        } else if event.gameEvent == .violationTeam1 || event.gameEvent == .violationTeam2 {
            return (eventIcon: nil,
                    eventText: "Foul",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)!) with a reckless charge on his opponent! Yellow for him.")
        } else if event.gameEvent == .nearmissTeam1 || event.gameEvent == .nearmissTeam2 {
            return (eventIcon: nil,
                    eventText: "Miss",
                    subtitleText: "Saved by the keeper! Kept position well and waited for \(playerNameFor(playerno: event.playerno, from: event.gameEvent)!)'s shot")
        }
        
        return (eventIcon: nil, eventText: "", subtitleText: "")
    }
    
    func playerNameFor(playerno: Int, from event: GamesEvent) -> String? {
        if "\(event)".contains("1") {
            return team1?.getPlayerByNumber(playerno)
        } else if "\(event)".contains("2") {
            return team2?.getPlayerByNumber(playerno)
        }
        return nil
    }
    
    func GameStarted() {
        playSound(sound: "fluit", isBackground: false)
        playSound(sound: "ambient", isBackground: true)
    }
    
    func GameEvent(_ time:Int, gameState: GameState, playerno:Int, gameEvent: GamesEvent) {
        DispatchQueue.main.sync {
            statusLabel.text = "\(gameState)".capitalized
            
            if gameEvent == .goalScoredTeam1 {
                score.goals1 += 1
            } else if gameEvent == .goalScoredTeam2 {
                score.goals2 += 1
            } else if gameEvent == .nearmissTeam1 || gameEvent == .nearmissTeam2 {
                playSound(sound: "_miss_\(arc4random() % 2)", isBackground: false)
            } else if gameEvent == .yellowCardTeam1 || gameEvent == .yellowCardTeam2 {
                playSound(sound: "_yellow_card", isBackground: false)
            } else if gameEvent == .redCardTeam1 || gameEvent == .redCardTeam2 {
                //
            } else if gameEvent == .timePass {
                timeLabel.text = "\(time)'"
                if time == 45 {
                    playSound(sound: "fluit", isBackground: false)
                }
                
                if(arc4random() % 90 == 0) {
                    playSound(sound: "_call_by_mom", isBackground: false)
                }
            }
            
            if gameEvent == .goalScoredTeam1 || gameEvent == .goalScoredTeam2 {
                playSound(sound: "_goal_\(arc4random() % 4)", isBackground: false)
                
                let notification = UILocalNotification()
                notification.alertTitle = "Goal scored!"
                notification.alertBody = "Score is \(score.goals1) - \(score.goals2), tap to see who scored"
                UIApplication.shared.scheduleLocalNotification(notification)
            }
            
            if(gameEvent != .timePass) {
                addEvent(time: time, gameState: gameState, playerno: playerno, gameEvent: gameEvent)
            }
            
            scoreLabel.text = "\(score.goals1) - \(score.goals2)"
        }
    }
    
    func addEvent(time:Int, gameState: GameState, playerno:Int, gameEvent: GamesEvent) {
        events.append(EventRow(time: time, gameState: gameState, playerno: playerno, gameEvent: gameEvent))
        let newItemIndex = IndexPath(row: events.count - 1, section: 0)
        eventsTableView.beginUpdates()
        eventsTableView.insertRows(at: [newItemIndex], with: .fade)
        eventsTableView.endUpdates()
        
        // Only scroll if no row expanded
        if selectedIndex == -1 {
            eventsTableView.scrollToRow(at: newItemIndex, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    func GameEnded(_ gameResult: GameResult) {
        stopSound()
        playSound(sound: "fluit", isBackground: false)
        playPauseBtn.isUserInteractionEnabled = false
        stopBtn.isUserInteractionEnabled = false
        soundBtn.isUserInteractionEnabled = false
        
        let alert = UIAlertController(title: "Match results", message: "\(gameResult)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { (action) in
            // NOOP
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func playSound(sound: String, isBackground: Bool, times: Int = 1) {
        if shouldPlaySound {
            let loops = times - 1
            let url = Bundle.main.url(forResource: sound, withExtension: "mp3")!
        
            do {
                if isBackground {
                    soundPlayerBg = try AVAudioPlayer(contentsOf: url)
                    guard let soundPlayerBg = soundPlayerBg else { return }
                    soundPlayerBg.prepareToPlay()
                    soundPlayerBg.volume = 0.3
                    soundPlayerBg.play()
                } else {
                    soundPlayer = try AVAudioPlayer(contentsOf: url)
                    guard let soundPlayer = soundPlayer else { return }
                    soundPlayer.prepareToPlay()
                    soundPlayer.volume = 1.0
                    soundPlayer.numberOfLoops = loops
                    soundPlayer.play()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func stopSound() {
        soundPlayer?.stop()
        soundPlayer = AVAudioPlayer()
        soundPlayer = nil
        soundPlayerBg?.stop()
        soundPlayerBg = AVAudioPlayer()
        soundPlayerBg = nil
    }

    func setupButtons() {
        let tapPlayPauseGesture = UITapGestureRecognizer(target: self, action: #selector(self.playPauseTapped))
        playPauseBtn.addGestureRecognizer(tapPlayPauseGesture)
        
        let stopGesture = UITapGestureRecognizer(target: self, action: #selector(self.stopTapped))
        stopBtn.addGestureRecognizer(stopGesture)
        
        let tapSoundGesture = UITapGestureRecognizer(target: self, action: #selector(self.soundTapped))
        soundBtn.addGestureRecognizer(tapSoundGesture)
    }
    
    func playPauseTapped() {
        // PauseGame method actually toggles the pauses/not paused state
        game.PauseGame()
        
        if game.shouldPauze {
            playPauseBtn.image = UIImage(named: "Play.png")
        } else {
            playPauseBtn.image = UIImage(named: "Pause.png")
        }
    }
    
    func stopTapped() {
        // If game is paused EndGame wont work until its unpaused...
        if game.shouldPauze {
            game.PauseGame()
        }
        game.EndGame()
    }
    
    func soundTapped() {
        shouldPlaySound = !shouldPlaySound
        
        if !shouldPlaySound {
            stopSound()
        } else {
            playSound(sound: "ambient", isBackground: true)
        }
    }
}
