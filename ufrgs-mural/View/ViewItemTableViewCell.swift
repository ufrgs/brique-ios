//
//  ViewItemTableViewCell.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/12/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

// View Item Image Cell

class ViewItemImageCell: UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    func configure(image: UIImage?) {
        
        if let photo = image {
            self.myImageView.image = photo
        } else {
            self.myImageView.image = UIImage(named: "noPhoto")
        }
        
    }
    
}

// View Item Text Cell

class ViewItemTextCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var orgaoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var personLabel: UILabel!
    
    let titles = ["Patrimônio", "Nome", "Origem", "Descrição", "Responsável pelo cadastro"]
    
    let titleAttributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Demibold", size: 17.0)! ]
    let textAttributes = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 16.0)! ]
    
    // MARK - Configuration methods
    
    func configure(number: String, name: String, orgao: String?, description: String, person: String?) {
        
        var orgaoName: String = "-"
        var personName: String = "-"
        
        if orgao != nil {
            orgaoName = orgao!
        }
        
        if person != nil {
            personName = person!
        }
        
        let texts = [number, name, orgaoName, description, personName]
        let labels = [numberLabel, nameLabel, orgaoLabel, descriptionLabel, personLabel]
        
        for i in 0..<titles.count {
            self.configureLabel(label: labels[i], title: titles[i], text: texts[i])
        }
    }
    
    private func configureLabel(label: UILabel?, title: String, text: String) {
        
        let titleAttrString = NSAttributedString(string: title + ": ", attributes: titleAttributes)
        let textAttrString = NSAttributedString(string: text, attributes: textAttributes)

        let content = NSMutableAttributedString()
        content.append(titleAttrString)
        content.append(textAttrString)
        
        label?.attributedText = content
    }
    
}

// View Item Button Cell

class ViewItemButtonCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var button: UIButton!
    weak var delegate: ViewItemButtonClickProtocol?
    
    let blue = UIColor(red: 86/255.0, green: 174/255.0, blue: 234/255.0, alpha: 1.0)
    
    // MARK: Configuration method
    
    func configure(userCanEdit: Bool, userCanRequest: Bool) {
        
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = blue
        button.layer.cornerRadius = 6.0
        button.clipsToBounds = true
        
        button.isUserInteractionEnabled = true
        
        if userCanEdit {
            button.setTitle("Editar", for: .normal)
        } else {
            if userCanRequest {
                button.setTitle("Solicitar transferência", for: .normal)
            } else {
                button.setTitle("Este bem já foi solicitado", for: .normal)
                button.setTitleColor(UIColor.black, for: .normal)
                button.backgroundColor = .clear
                button.isUserInteractionEnabled = false
            }
            
        }
        
        self.button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
    }
    
    // MARK: - Button action
    
    @objc func buttonClicked() {
        self.delegate?.buttonClicked()
    }
    
}
