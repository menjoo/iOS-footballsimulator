//
//  SimulationViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit
import AVFoundation

class SimulationViewController: UIViewController, UITableViewDataSource, GameEventSource {

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
    
    var soundPlayerBg: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventsTableView.dataSource = self
        self.eventsTableView.allowsSelection = false
        self.game.delegate = self
        
        scoreLabel.text = "0 - 0"
        statusLabel.text = "Not started"
        timeLabel.text = ""
        
        flagIconTeam1.image = team1?.flag
        nameLabelTeam1.text = team1?.fullname.uppercased()
        flagIconTeam2.image = team2?.flag
        nameLabelTeam2.text = team2?.fullname.uppercased()
        game.startGame(team1!, teamb: team2!, gameMode: .quick)
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
    
    func eventDataFor(_ event: EventRow) -> (eventIcon: UIImage?, eventText: String, subtitleText: String) {
        if event.gameEvent == .cornerGivenTeam1 || event.gameEvent == .corderGivenTeam2 {
            return (eventIcon: UIImage(named: "corner.png"),
                    eventText: "Corner",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) is taking the kick")
        } else if event.gameEvent == .goalScoredTeam1 || event.gameEvent == .goalScoredTeam2 {
            return (eventIcon: UIImage(named: "footbal.png"),
                    eventText: "Goaaaaalll!!!",
                    subtitleText: "Insane shot by \(playerNameFor(playerno: event.playerno, from: event.gameEvent))! A goal to remember!")
        } else if event.gameEvent == .playerInjuredTeam1 || event.gameEvent == .playerInjuredTeam2 {
            return (eventIcon: UIImage(named: "injury.png"),
                    eventText: "Injury",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) is in serious pain!")
        } else if event.gameEvent == .playerSwitchTeam1 || event.gameEvent == .playerSwitchTeam2 {
            return (eventIcon: UIImage(named: "sub.png"),
                    eventText: "Substitution",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) is being subbed")
        } else if event.gameEvent == .yellowCardTeam1 || event.gameEvent == .yellowCardTeam2 {
            return (eventIcon: UIImage(named: "card_yellow.png"),
                    eventText: "Yellow card",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) almost injured his opponent")
        } else if event.gameEvent == .redCardTeam1 || event.gameEvent == .redCardTeam2 {
            return (eventIcon: UIImage(named: "card_red.png"),
                    eventText: "Red card",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) is off!  Took down his opponent who was clearly in on goal")
        } else if event.gameEvent == .violationTeam1 || event.gameEvent == .violationTeam2 {
            return (eventIcon: nil,
                    eventText: "Foul",
                    subtitleText: "\(playerNameFor(playerno: event.playerno, from: event.gameEvent)) with a reckless charge on his opponent! Yellow for him.")
        } else if event.gameEvent == .nearmissTeam1 || event.gameEvent == .nearmissTeam2 {
            return (eventIcon: nil,
                    eventText: "Miss",
                    subtitleText: "Saved by the keeper! Kept position well and waited for \(playerNameFor(playerno: event.playerno, from: event.gameEvent))'s shot")
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
                playSound(sound: "fluit", isBackground: false)
                playSound(sound: "_yellow_card", isBackground: false)
            } else if gameEvent == .redCardTeam1 || gameEvent == .redCardTeam2 {
                playSound(sound: "fluit", isBackground: false)
            } else if gameEvent == .timePass {
                timeLabel.text = "\(time)'"
                if time == 45 {
                    playSound(sound: "fluit", isBackground: false, times: 2)
                }
                
                if(arc4random() % 90 == 0) {
                    playSound(sound: "_call_by_mom", isBackground: false)
                }
            }
            
            if gameEvent == .goalScoredTeam1 || gameEvent == .goalScoredTeam2 {
                playSound(sound: "_goal_\(arc4random() % 4)", isBackground: false)
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
        eventsTableView.scrollToRow(at: newItemIndex, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    func GameEnded(_ gameResult: GameResult) {
        stopSound()
        playSound(sound: "fluit", isBackground: false, times: 3)
    }
    
    func playSound(sound: String, isBackground: Bool, times: Int = 1) {
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
    
    func stopSound() {
        soundPlayer?.stop()
        soundPlayer = nil
        soundPlayerBg?.stop()
        soundPlayerBg = nil
    }

}
