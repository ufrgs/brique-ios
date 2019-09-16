//
//  CreateItemInfoCell.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class CreateItemFieldCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var line: UIView!
    
    // MARK: - Properties
    
    let lineColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
    let enabledContentColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
    let enabledTitleColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
    
    let disabledColor = UIColor(red: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1.0)
    
    func configure(enabled: Bool, lineIsVisible: Bool) {
        if enabled {
            self.titleLabel.textColor = enabledTitleColor
            self.contentLabel.textColor = enabledContentColor
        } else {
            self.titleLabel.textColor = disabledColor
            self.contentLabel.textColor = disabledColor
        }
        
        line.isHidden = !lineIsVisible
        line.backgroundColor = lineColor
        
        self.titleLabel.text = self.titleLabel.text?.uppercased()
        self.backgroundColor = .clear
    }
    
}

class CreateItemButtonCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
}

class CreateItemImageCell: UITableViewCell {
    
    @IBOutlet weak var imageSelectionView: ImageSelectionView!
    weak var delegate: PickImageProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    func setImage(image: UIImage?) {
        imageSelectionView.setImage(image: image)
    }
    
}
