//
//  Item.swift
//  ufrgs-alerta
//
//  Created by Augusto on 18/09/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class Item {
    
    // MARK: - Properties
    
    var number: String
    var name: String
    var description: String
    
    var nrSeq: Int?
    var image: UIImage?
    
    var didFetchImage = false
    
    var sourceOrgao: Orgao?
//    var destinationOrgao: Orgao?
    
//    var registrationDate: String?
    
    var userCanEdit = false
    var userCanRequest = false
    
    var personWhoRegistered: String?
    
    
    // MARK: - Initializers
    
    init() {
        self.number = ""
        self.name = ""
        self.description = ""
    }
    
    init(number: String, name: String, source: String, description: String) {
        self.number = number
        self.name = name
        self.description = description
    }
    
    // MARK: - Auxuliar functions
    
    func toDict() -> [String: Any] {
        
        var dict = [String: Any]()
        
        dict.updateValue(number, forKey: "NrPatrimonio")
        dict.updateValue(name, forKey: "Nome")
        dict.updateValue(description, forKey: "Descricao")
        
        if let o = self.sourceOrgao {
            dict.updateValue(o.name, forKey: "NomeOrgao")
            dict.updateValue(o.initials, forKey: "SiglaOrgao")
            dict.updateValue(o.code, forKey: "CodOrgao")
        }
        
        return dict
    }
    
}
