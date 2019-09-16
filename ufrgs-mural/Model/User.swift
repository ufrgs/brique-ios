//
//  User.swift
//  ufrgs-alerta
//
//  Created by Augusto on 01/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation

class User {
    
    // MARK: - Properties
    
    static let current = User()
    let defaults = UserDefaults.standard
    let tokenKey = "token"
    
    // MARK: - Public functions
    
    func save(token: String) {
        defaults.set(token, forKey: tokenKey)
    }
    
    func delete() {
        defaults.removeObject(forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return defaults.object(forKey: tokenKey) as? String
    }
    
    func isLogged() -> Bool {
        return (getToken() != nil)
    }
    
}
