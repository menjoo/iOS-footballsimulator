//
//  TeamsRepository.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 02/12/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import Foundation

class TeamsRepository {
    
    func getTeams() -> [Team] {
        var teams = [Team]()
        let urlString = "https://bitbucket.org/mennomorsink/football-simulator-publics/raw/ca8e194dad8b394c26938f469668b80dfcb0fd86/teams.json"
        if let url = NSURL(string: urlString) {
            if let data = try? Data(contentsOf: url as URL) {
                //do {
                    let parsedData = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [AnyObject]
                    for item in parsedData {
                        let name = item["name"] as! String
                        let fullname = item["fullname"] as! String
                        let players = item["players"] as! [String]
                        let strength = item["strength"] as! Int
                        let team = Team(name: name, fullname: fullname, players: players, strength: strength)
                        teams.append(team)
                    }
//                    print(parsedData)
//                } catch let error as NSError {
//                    print(error)
//                }
            }
        }
        return teams
    }
}
