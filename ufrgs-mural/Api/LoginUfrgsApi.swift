//
//  LoginUfrgsApi.swift
//  ufrgs-alerta
//
//  Created by Augusto on 02/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LoginUfrgsApi : UfrgsApi {
    
    
    // MARK: - Post methods
    
    func authenticate(id: String, password: String, completion: @escaping (String?) -> ()) {}
    
    // MARK: - Auxiliar functions
    
    private func buildParams(id: String, password: String) -> [String:String] {
        return [String:String]()
    }
}
