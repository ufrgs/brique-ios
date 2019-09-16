//
//  ItemUfrgsApi.swift
//  ufrgs-alerta
//
//  Created by Augusto on 02/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import SwiftyJSON

class ItemUfrgsApi : UfrgsApi {
    
    // MARK: - Post methods
    
    func create(body: [String: Any], completion: @escaping (Bool, String, Int?) -> ()) {}
    
    func updateImage(nrSeq: Int, body: [String: Any], completion: @escaping (Bool, String) -> ()) {}
    
    func update(nrSeq: Int, body: [String: Any], completion: @escaping (Bool, String) -> ()) {}
    
    // MARK: - GET methods
    
    func get(id: String, completion: @escaping (JSON?, String) -> ()) {}
    
    func getItems(page: Int, completion: @escaping (JSON?, JSON?) -> ()) {}
    
    func getItemsFromUser(page: Int, completion: @escaping (JSON?, JSON?) -> ()) {}
    
    func getItemsWithTerm(page: Int, term: String, completion: @escaping (JSON?, JSON?) -> ()) {}
    
    func getImage(nrSeq: Int, completion: @escaping (Data?, String?) -> ()) {}
    
    func getItemInfo(nrSeq: Int, completion: @escaping (JSON?, String?) -> ()) {}
    
    // MARK: - DELETE method
    
    func delete(nrSeq: Int, completion: @escaping (Bool, String) -> ()) {}

    // MARK: - Auxiliar methods
    
    func buildImageHeader() -> HTTPHeaders {
        return self.buildHeader()
    }
    
}
