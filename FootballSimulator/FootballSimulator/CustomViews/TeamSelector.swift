//
//  TeamSelector.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

class TeamSelector: UIScrollView, UIScrollViewDelegate {
    
    var repository: TeamsRepository = TeamsRepository()
    var teams: [Team] = [Team]()
    var itemWidth: Int = 0
    var isLabelPositionTop: Bool = true
    
    private var current: Int = 0
    
    var selectedTeam: Team {
        return teams[current]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        teams = repository.getTeams()
    }
    
    override func layoutSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        itemWidth = Int(bounds.width)
        isLabelPositionTop = self.frame.origin.y < UIScreen.main.bounds.height / 2
        
        self.showsHorizontalScrollIndicator = false
        self.isPagingEnabled = true
        self.delegate = self
        self.contentSize = CGSize(width: teams.count * itemWidth, height: Int(frame.height))
        
        for index in 0 ..< teams.count {
            let teamView = createView(for: index)
            
            self.addSubview(teamView)
        }
    }

    private func createView(for index: Int) -> UIView {
        let teamView = UIView(frame: CGRect(x: index * itemWidth, y: 0, width: itemWidth, height: Int(frame.height)))

        var labelPosY: Int = 15
        if isLabelPositionTop {
            labelPosY = Int(teamView.frame.height) - 15
        }
        
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: itemWidth, height: 40))
        teamView.addSubview(nameLabel)
        nameLabel.text = teams[index].fullname.uppercased()
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        nameLabel.center = CGPoint(x: Int(teamView.center.x) % itemWidth, y: labelPosY);
        let imageView = UIImageView(image: teams[index].flag!)
        imageView.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
        teamView.addSubview(imageView)
        imageView.center = CGPoint(x: Int(teamView.center.x) % itemWidth, y: Int(teamView.center.y));
        
        return teamView
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        current = Int(self.contentOffset.x) / itemWidth
        print("selected is \(current)")
    }
}
