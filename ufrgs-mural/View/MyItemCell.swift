//
//  MuralItemCell.swift
//  ufrgs-mural
//
//  Created by Augusto on 04/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit
import Hero

class MyItemCell: UITableViewCell {
    
    let cornerRadiusValue: CGFloat = 4.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var lineUnderView: UIView!
    
    let borderColor = UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1.0)
    let defaultBGColor = UIColor.white
    let selectedBGColor = UIColor(red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureHero()
    }
    
    func configure(title: String, number: String, description: String?, image: UIImage?) {
        self.titleLabel.text = title
        self.numberLabel.text = number
        self.descriptionLabel.text = description
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.photoImageView.image = image
        
        self.configureCardView()
    }
    
    private func configureHero() {
        
//        self.cardView.hero.id = HeroId.myItemCard
//        self.titleLabel.hero.id = HeroId.myItemTitle
//        self.descriptionLabel.hero.id = HeroId.myItemDescription
//        self.numberLabel.hero.id = HeroId.myItemNumber
    }
    
    private func configureCardView() {
        self.cardView.clipsToBounds = true
        self.cardView.layer.cornerRadius = cornerRadiusValue
        
        self.lineUnderView.clipsToBounds = true
        self.lineUnderView.layer.cornerRadius = cornerRadiusValue
        
//        self.cardView.layer.borderColor = borderColor.cgColor
//        self.cardView.layer.borderWidth = 0.8
        
        self.cardView.backgroundColor = defaultBGColor
    }
    
    func animateSelection() {
        self.cardView.backgroundColor = selectedBGColor
        
        UIView.animate(withDuration: 1.0) {
            self.cardView.backgroundColor = self.defaultBGColor
        }
    }
    
}
