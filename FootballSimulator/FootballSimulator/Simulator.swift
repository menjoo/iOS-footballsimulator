//
//  simulator.swift
//  EK16Simulator
//
//  Created by John Gorter on 13/06/16.
//  Copyright © 2016 John Gorter. All rights reserved.
//
import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class Team {
    init(name:String, fullname:String, players:[String], strength:Int) {
        self.name = name
        self.fullname = fullname
        self.strength = strength
        self.players = players
    }
    
    // use a stored property for the name
    open let name:String
    open let fullname:String
    open let strength:Int
    open let players:[String]
    
    //use a calculated property for the image
    open var flag : UIImage? {
        get { return UIImage(named: "\(name).ico") }
    }
    
    open func getPlayerByNumber(_ playerno:Int) -> String{
        if playerno > 0 && self.players.count >= playerno {
          return self.players[playerno-1]
        }
        return "unknown player"
    }
}


public enum SimulationMode:Int {
    case realTime = 0
    case normal
    case slow
    case quick
    case veryQuick
}

public enum GameResult {
    case undefined
    case team1Won(scorea:Int, scoreb:Int)
    case team2Won(scorea:Int, scoreb:Int)
    case draw
}

enum GameState : Int {
    case notStarted
    case kickOff
    case started
    case pausing
    case resuming
    case ending
    case ended
}

enum GamesEvent : Int {
    case goalScoredTeam1 = 0
    case goalScoredTeam2
    case nearmissTeam1
    case nearmissTeam2
    case playerInjuredTeam1
    case playerInjuredTeam2
    case playerSwitchTeam1
    case playerSwitchTeam2
    case violationTeam1
    case violationTeam2
    case cornerGivenTeam1
    case corderGivenTeam2
    case yellowCardTeam1
    case yellowCardTeam2
    case redCardTeam1
    case redCardTeam2
    case timePass
    case nothing
    
    static var count: Int { return GamesEvent.nothing.hashValue + 1}
}


// OUR INTERFACE in C#
protocol GameEventSource {
    func GameStarted()
    func GameEvent(_ time:Int, gameState: GameState, playerno:Int, gameEvent: GamesEvent)
    func GameEnded(_ gameResult: GameResult)
}



open class Game {
    
    var Team1:Team?
    var Team2:Team?
    var result:GameResult = .undefined
    var delegate:GameEventSource?
    var shouldStop:Bool = false
    var shouldPauze:Bool = false
    
    
    func PauseGame(){
        shouldPauze = !shouldPauze
    }
    
    func EndGame(){
        shouldStop = true
    }
    
    func startGame(_ teama:Team, teamb:Team, gameMode:SimulationMode = SimulationMode.normal){
        self.Team1 = teama;
        self.Team2 = teamb;
        var score:(goala:Int, goalb:Int) = (goala: 0, goalb: 0);
        
        var gameState:GameState = .notStarted;
        var interval:Double = 1;
        
        switch (gameMode){
        case .realTime: interval = 60
        case .slow: interval = 5
        case .quick: interval = 0.5
        case .veryQuick: interval = 0.001
        default: interval = 1
        }
        
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
            //simulate 90 minutes
            self.delegate?.GameStarted()
            gameState = .started;
            
            
            for i in 1...105 {
                if self.shouldStop { break }
                if self.shouldPauze {
                    while self.shouldPauze {
                        Thread.sleep(forTimeInterval: 1)
                    }
                }
                
                let gameMinute = i > 60 ? i - 15 : i < 45 ? i : 45
                
                if i == 1 {
                    gameState = .kickOff
                    self.delegate?.GameEvent(gameMinute, gameState: gameState, playerno: 0, gameEvent: .timePass)
                    gameState = .started
                }
                
                if i == 45{
                    gameState = .pausing
                    self.delegate?.GameEvent(gameMinute, gameState: gameState, playerno: 0, gameEvent: .timePass)
                }
                
                if i == 60{
                    gameState = .resuming
                    self.delegate?.GameEvent(gameMinute, gameState: gameState, playerno: 0, gameEvent: .timePass)
                    
                }

                if (i < 45 || i > 60){
                    gameState = .started
                    let gameevent:GamesEvent = self.getRandomGameEvent(i > 60 ? i - 15 : i)
                    var player: Int = 0;
                    if (self.needsPlayer(gameevent) > 0) {
                        player = self.getPlayerNumber(gameevent)
                    }
                    if gameevent == .goalScoredTeam1{ score.goala += 1 }
                    if gameevent == .goalScoredTeam2{ score.goalb += 1 }
                    if gameevent != .nothing { self.delegate?.GameEvent(gameMinute, gameState:gameState, playerno:player, gameEvent: gameevent) }
                
                
                self.delegate?.GameEvent(gameMinute, gameState: gameState, playerno: 0, gameEvent: .timePass)
                }
                if i == 105 {
                    gameState = .ending
                    self.delegate?.GameEvent(gameMinute, gameState: gameState, playerno: 0, gameEvent: .timePass)
                    
                }
                
                Thread.sleep(forTimeInterval: interval)
            }
            gameState = .ended
            self.delegate?.GameEvent(90, gameState: gameState, playerno: 0, gameEvent: .timePass)
            
            if score.goala == score.goalb { self.delegate?.GameEnded(.draw)}
            if score.goala < score.goalb { self.delegate?.GameEnded(.team2Won(scorea: score.goala, scoreb: score.goalb))}
            if score.goala > score.goalb  { self.delegate?.GameEnded(.team1Won(scorea: score.goala, scoreb: score.goalb))}
            
            
        })
        
    }
    func getPlayerNumber (_ gameEvent:GamesEvent) -> Int {
        if (gameEvent == .goalScoredTeam1 || gameEvent == .goalScoredTeam2){
            return Int(arc4random() % 5) + 7
        }
        return Int(arc4random()%11) + 1
    }
    
    func needsPlayer(_ gameEvent:GamesEvent) -> Int {
        if (gameEvent == .goalScoredTeam1 ||
            gameEvent == .goalScoredTeam2 ||
            gameEvent == .playerInjuredTeam1 ||
            gameEvent == .playerInjuredTeam2 ||
            gameEvent == .yellowCardTeam1 ||
            gameEvent == .yellowCardTeam2 ||
            gameEvent == .redCardTeam1 ||
            gameEvent == .redCardTeam2
            ) { return 1; }
        if (gameEvent == .playerSwitchTeam1 || gameEvent == .playerSwitchTeam2){ return 2; }
        return 0;
    }
    
    func getRandomGameEvent(_ minute:Int) -> GamesEvent {
        // de wedstrijd is zo:
        // 1ste kwartier: 10% kans op gebeurtenis
        // erna 20% kans
        // laatste kwartier: 30% kans op gebeurtenis
        let chance = (minute < 15) ? 10 : (minute < 75) ? 5 : 3
        // 20% kans op een gebeurtenis
        if  Int(arc4random()) % chance == 1 {
            let l = GamesEvent.count
            let random =  Int(arc4random()) % l
            let result = GamesEvent(rawValue:random)!
            if (result == .goalScoredTeam1 || result == .goalScoredTeam2){
                return GoalResult(result)
            }
            
            return result
            
        }
        return GamesEvent.nothing
        
    }
    
    func GoalResult (_ result: GamesEvent) -> GamesEvent {
        if (result == .goalScoredTeam1){
            let diff = abs((self.Team2?.strength)! - (self.Team1?.strength)!)
            let divider = diff < 6 ? 2 : diff < 15 ? 3 : 4;
            if self.Team2?.strength > self.Team1?.strength{
                // 30% kans dat dat ook echt kan, een minder sterk team tegen een sterker team scoren, dus de 66%       likeable
                if (Int(arc4random()) % divider == 0) { return result } else { return .nearmissTeam1 }
            } else {
                if (Int(arc4random()) % divider != 0) { return result } else { return .nearmissTeam1 }
            }
        }
        
        if (result == .goalScoredTeam2){
            let diff = abs((self.Team1?.strength)! - (self.Team2?.strength)!)
            let divider = diff < 6 ? 2 : diff < 15 ? 3 : 4;
            if self.Team1?.strength > self.Team2?.strength{
                // 30% kans dat dat ook echt kan, een minder sterk team tegen een sterker team scoren, dus de 66%       likeable
                if (Int(arc4random()) % divider == 0) { return result } else { return .nearmissTeam2 }
            } else {
                if (Int(arc4random()) % divider != 0) { return result } else { return .nearmissTeam2 }
            }
        }
        return .nothing
    }
}

