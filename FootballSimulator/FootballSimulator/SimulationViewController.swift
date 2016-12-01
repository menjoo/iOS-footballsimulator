//
//  SimulationViewController.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventsTableView.dataSource = self
        self.eventsTableView.allowsSelection = false
        self.game.delegate = self
        
        scoreLabel.text = "0 - 0"
        statusLabel.text = "Not started"
        
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
            return (eventIcon: UIImage(named: "corner.png"), eventText: "Corner", subtitleText: "")
        } else if event.gameEvent == .goalScoredTeam1 || event.gameEvent == .goalScoredTeam2 {
            return (eventIcon: UIImage(named: "footbal.png"), eventText: "Goaaaaalll!!!", subtitleText: "Insane shot by \(event.playerno)! A goal to remember!")
        } else if event.gameEvent == .playerInjuredTeam1 || event.gameEvent == .playerInjuredTeam2 {
            return (eventIcon: UIImage(named: "injury.png"), eventText: "Injury", subtitleText: "\(event.playerno) broke his ankle")
        } else if event.gameEvent == .playerSwitchTeam1 || event.gameEvent == .playerSwitchTeam2 {
            return (eventIcon: UIImage(named: "sub.png"), eventText: "Substitution", subtitleText: "\(event.playerno) is being subbed")
        } else if event.gameEvent == .yellowCardTeam1 || event.gameEvent == .yellowCardTeam2 {
            return (eventIcon: UIImage(named: "card.png"), eventText: "Yellow card", subtitleText: "\(event.playerno) almost injured his opponent")
        } else if event.gameEvent == .redCardTeam1 || event.gameEvent == .redCardTeam2 {
            return (eventIcon: UIImage(named: "card.png"), eventText: "Red card", subtitleText: "\(event.playerno) is out!  Took down his opponent who was in on goal")
        } else if event.gameEvent == .violationTeam1 || event.gameEvent == .violationTeam2 {
            return (eventIcon: nil, eventText: "Foul", subtitleText: "\(event.playerno) with a reckless charge! Yellow for him.")
        } else if event.gameEvent == .nearmissTeam1 || event.gameEvent == .nearmissTeam2 {
            return (eventIcon: nil, eventText: "Miss", subtitleText: "Saved by the keeper! What a shot by by \(event.playerno)")
        }
        
        return (eventIcon: nil, eventText: "", subtitleText: "")
    }
    
    func GameStarted() {
        
    }
    
    func GameEvent(_ time:Int, gameState: GameState, playerno:Int, gameEvent: GamesEvent) {
        DispatchQueue.main.sync {
            statusLabel.text = "\(gameState)".capitalized
            
            switch(gameEvent) {
            case .goalScoredTeam1:
                score.goals1 += 1
                break
            case .goalScoredTeam2:
                score.goals2 += 1
                break
            case .timePass:
                timeLabel.text = "\(time)'"
                break;
            default: break
                //
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
        
    }

}
