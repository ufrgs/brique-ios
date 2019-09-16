//
//  MuralItemCell.swift
//  ufrgs-mural
//
//  Created by Augusto on 26/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class MuralItemCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MuralItemCell"
    let constraintId = "abaporu"
    let cornerRadiusValue: CGFloat = 4.0
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lineUnderView: UIView!
    
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let borderColor = UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1.0)
    let defaultBGColor = UIColor.white
    
    // MARK: - Configuration methods
    
    func configure(name: String, image: UIImage?, hasFetchedImage: Bool) {
        
        self.configureNameLabel(name: name)
        self.configureImageView(image: image, hasFetchedImage: hasFetchedImage)
        self.configureCardView()
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    private func configureNameLabel(name: String) {
        
        self.nameLabel.numberOfLines = 0
        self.nameLabel.text = name
        
    }
    
    private func configureImageView(image: UIImage?, hasFetchedImage: Bool) {
        
        self.itemImageView.clipsToBounds = true
        
        if let photo = image {
            self.itemImageView.image = photo
            self.addAspectRatioConstraint()
            self.spinner.removeFromSuperview()
        } else {
            if hasFetchedImage {
//                self.itemImageView.image = UIImage(named: "noPhoto")
                self.spinner.removeFromSuperview()
                self.itemImageView.image = nil
                self.addZeroHeightConstraint()
                
//                aspectRatioConstraint.
            } else {
                self.configureSpinner()
                self.itemImageView.image = nil
                self.addAspectRatioConstraint()
                self.itemImageView.addSubview(spinner)
            }
        }
        
    }
    
    private func addAspectRatioConstraint() {
        
        removeImageViewConstraint()
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: itemImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: itemImageView,
            attribute: .width,
            multiplier: 1.0,
            constant: 0
        )
        constraint.identifier = self.constraintId
        
        itemImageView.addConstraint(constraint)
    }
    
    private func addZeroHeightConstraint() {
        
        removeImageViewConstraint()
        
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: itemImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 0.0
        )
        constraint.identifier = self.constraintId
        
        itemImageView.addConstraint(constraint)
    }
    
    private func removeImageViewConstraint() {
        for c in itemImageView.constraints {
            if c.identifier == self.constraintId {
                itemImageView.removeConstraint(c)
            }
        }
    }
    
    private func configureSpinner() {

        spinner.startAnimating()
        spinner.frame = CGRect(origin: .zero, size: itemImageView.frame.size)

    }
    
    private func configureCardView() {
        
        self.cardView.clipsToBounds = true
        self.cardView.layer.cornerRadius = cornerRadiusValue
        
        self.lineUnderView.clipsToBounds = true
        self.lineUnderView.layer.cornerRadius = cornerRadiusValue
        
        self.cardView.clipsToBounds = true
        self.cardView.backgroundColor = defaultBGColor
        
    }
    
}
