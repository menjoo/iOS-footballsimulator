//
//  TeamSelector.swift
//  FootballSimulator
//
//  Created by Menno Morsink on 30/11/2016.
//  Copyright © 2016 Menno Morsink. All rights reserved.
//

import UIKit

class TeamSelector: UIScrollView, UIScrollViewDelegate {
    
    let teams = ["netherlands", "belgium", "germany"]
    var itemWidth: Int = 0
    var isLabelPositionTop: Bool = true
    
    private var current: Int = 0
    
    var selectedTeamIndex: Int {
        return current
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        nameLabel.text = teams[index].uppercased()
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        nameLabel.center = CGPoint(x: Int(teamView.center.x) % itemWidth, y: labelPosY);
        
        let imageName = "\(teams[index]).png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 120)
        teamView.addSubview(imageView)
        imageView.center = CGPoint(x: Int(teamView.center.x) % itemWidth, y: Int(teamView.center.y));
        
        return teamView
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        current = Int(self.contentOffset.x) / itemWidth
        print("selected is \(current)")
    }
}
