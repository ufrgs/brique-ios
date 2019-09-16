//
//  UfrgsApi.swift
//  ufrgs-alerta
//
//  Created by Augusto on 01/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UfrgsApi {
    
    // MARK: - Properties
    
    let baseUrl = ""
    
    // MARK: - Auxiliar functions
    
    func buildHeader() -> HTTPHeaders {
        return [ "" : "" ]
    }
    
    func getHTTPCode(json: JSON) -> HTTPStatusCode {
        let str = String(describing: json["code"])
        
        if let value = Int(str) {
            if let code = HTTPStatusCode(rawValue: value) {
                return code
            }
        }
        
        return HTTPStatusCode.unknown
    }
}
