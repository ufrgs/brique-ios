//
//  ItemRequestRepository.swift
//  ufrgs-mural
//
//  Created by Augusto on 15/01/2019.
//  Copyright © 2019 Augusto. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class ItemRequestRepository {
    
    // MARK: - Properties
    
    private var api = ItemRequestUfrgsApi()
    
    // MARK: - CREATE
    
    public func create(nrSeqItem: Int, message: String, completion: @escaping (Bool, String) -> ()) {
        
        let body = createBody(nrSeqItem: nrSeqItem, message: message)
        
        api.create(body: body) { (success, message) in
            completion(success, message)
        }
        
    }
    
    // MARK: - Private methods
    
    private func createBody(nrSeqItem: Int, message: String) -> [String: Any] {
        
        var dict = [String: Any]()
        
        dict.updateValue(message, forKey: "MensagemSolicitacao")
        dict.updateValue(nrSeqItem, forKey: "NrSeqItem")
        
        return dict
    }

}
