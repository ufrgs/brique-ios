//
//  AlertRepository.swift
//  ufrgs-alerta
//
//  Created by Augusto on 01/10/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class ItemRepository {
    
    // MARK: - Properties
    
    private var api = ItemUfrgsApi()
    
    // MARK: - CREATE
    
    public func create(item: Item, completion: @escaping (Bool, String, Int?) -> ()) {
        
        let body = item.toDict()
        
        api.create(body: body) { (success, message, nrSeq) in
            completion(success, message, nrSeq)
        }
        
    }
    
    // MARK: - READ
    
    public func readPageWithImages(page: Int, pageCompletion: @escaping ([Item], Int, Int) -> (), itemCompletion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.api.getItems(page: page) { (itemsJson, metaJson) in
                
                let newItems = self.itemsFrom(json: itemsJson)
                
                if itemsJson != JSON.null {
                    
                    for item in newItems {
                        
                        DispatchQueue.global(qos: .background).async {
                            
                            self.getImage(nrSeq: item.nrSeq!, completion: { (image, _) in
                                item.image = image
                                item.didFetchImage = true
                                
                                itemCompletion()
                            })
                        }
                    }
                }
                
                // procura nos metadados pela última página de resultados
                var lastPage = page
                var itemsCount = newItems.count
                
                if let meta = metaJson {
                    if let pageCount = Int(String(describing: meta["pageCount"])) {
                        lastPage = pageCount
                    }
                    
                    if let totalCount = Int(String(describing: meta["totalCount"])) {
                        itemsCount = totalCount
                    }
                }
                
                DispatchQueue.main.async {
                    pageCompletion(newItems, lastPage, itemsCount)
                }
            }
        }
    }
    
    public func readPageFromUser(page: Int, pageCompletion: @escaping ([Item], Int) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.api.getItemsFromUser(page: page) { (itemsJson, metaJson) in
                
                let newItems = self.itemsFrom(json: itemsJson)
                
                // procura nos metadados pela última página de resultados
                var lastPage = page
                
                if let meta = metaJson {
                    if let pageCount = Int(String(describing: meta["pageCount"])) {
                        lastPage = pageCount
                    }
                }
                
                DispatchQueue.main.async {
                    pageCompletion(newItems, lastPage)
                }
            }
        }
    }
    
    public func readPageFromUserWithImage(page: Int, pageCompletion: @escaping ([Item], Int) -> (), itemCompletion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.api.getItemsFromUser(page: page) { (itemsJson, metaJson) in
                
                let newItems = self.itemsFrom(json: itemsJson)
                
                // procura nos metadados pela última página de resultados
                var lastPage = page
                
                if let meta = metaJson {
                    if let pageCount = Int(String(describing: meta["pageCount"])) {
                        lastPage = pageCount
                    }
                }
                
                // get image for each item in the list
                for item in newItems {
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        self.getImage(nrSeq: item.nrSeq!, completion: { (image, _) in
                            item.image = image
                            item.didFetchImage = true
                            
                            itemCompletion()
                        })
                    }
                }
                
                DispatchQueue.main.async {
                    pageCompletion(newItems, lastPage)
                }
            }
        }
    }
    
    public func readPageWithTerm(page: Int, term: String, pageCompletion: @escaping ([Item], Int, Int) -> (), itemCompletion: @escaping () -> ()) {
        
        let parsedString = Helper.parseString(original: term)
        
        DispatchQueue.global(qos: .background).async {
            
            self.api.getItemsWithTerm(page: page, term: parsedString) { (itemsJson, metaJson) in
                
                let newItems = self.itemsFrom(json: itemsJson)
                
                if itemsJson != JSON.null {
                    
                    for item in newItems {
                        
                        DispatchQueue.global(qos: .background).async {
                            
                            self.getImage(nrSeq: item.nrSeq!, completion: { (image, _) in
                                item.image = image
                                item.didFetchImage = true
                                
                                itemCompletion()
                            })
                        }
                    }
                }
                
                // procura nos metadados pela última página de resultados
                var lastPage = page
                var itemsCount = newItems.count
                
                if let meta = metaJson {
                    if let pageCount = Int(String(describing: meta["pageCount"])) {
                        lastPage = pageCount
                    }
                    
                    if let totalCount = Int(String(describing: meta["totalCount"])) {
                        itemsCount = totalCount
                    }
                }
                
                DispatchQueue.main.async {
                    pageCompletion(newItems, lastPage, itemsCount)
                }
                
            }
            
        }
        
    }
    
    
    public func read(id: String, completion: @escaping (Item?, String) -> ()) {
        
        api.get(id: id) { (json, message) in
            
            var item = Item()
            
            if let result = json {
                
                item = self.itemFrom(json: result)
                completion(item, message)
                
            } else {
                
                completion(nil, message)
                
            }
        }
    }
    
    public func getItemInfo(nrSeq: Int, completion: @escaping (Item?) -> ()) {
        
        let item = Item()
        
        api.getItemInfo(nrSeq: nrSeq) { (itemJson, message) in
            
            if let json = itemJson {
                
                if let nrSeq = Int(String(describing: json["NrSeqItem"])) {
                    item.nrSeq = nrSeq
                }
                
                item.name = String(describing: json["Nome"])
                item.description = String(describing: json["Descricao"])
                item.personWhoRegistered = String(describing: json["NomePessoaCadastro"])
                item.number = String(describing: json["NrPatrimonio"])
                
                let orgao = Orgao()
                orgao.code = String(describing: json["CodOrgaoOrigem"])
                orgao.name = String(describing: json["NomeOrgaoOrigem"])
                
                item.sourceOrgao = orgao
                
                completion(item)
                return
            }
            
            completion(nil)
        }
        
    }
    
    public func getImage(nrSeq: Int, completion: @escaping (UIImage?, String?) -> ()) {
        
        api.getImage(nrSeq: nrSeq) { (response, message) in
            
            if let data = response {
                if let image = UIImage(data: data) {
                    completion(image, nil)
                    return
                }
            }
            
            completion(nil, message)
        }
        
    }
    
    public func getItemOrgao(id: String, completion: @escaping (Orgao?, String?) -> ()) {
        api.get(id: id) { (json, message) in
            let orgao = Orgao()
            
            if let result = json {
                
                orgao.name = String(describing: result["NomeOrgao"])
                orgao.initials = String(describing: result["SiglaOrgao"])
                orgao.code = String(describing: result["CodOrgao"])
                
                completion(orgao, message)
            } else {
                completion(nil, message)
            }
        }
    }
    
    // MARK: - UPDATE
    
    // Update image
    public func updateImage(nrSeq: Int, image: UIImage, completion: @escaping (Bool, String) -> ()) {
        
        let compression = getCompressionQuality(size: image.size.height)
        
        if let imageData = UIImageJPEGRepresentation(image, compression) {
            
            DispatchQueue.global(qos: .background).async {
                
                var body = [String: Any]()
                let hexString = imageData.hexEncodedString()
                
                body.updateValue(hexString, forKey: "image")
                
                DispatchQueue.main.async {
                    self.api.updateImage(nrSeq: nrSeq, body: body) { (success, message) in
                        completion(success, message)
                    }
                }
            }
        }
    }
    
    // Update text fields
    public func update(nrSeq: Int, item: Item, completion: @escaping (Bool, String) -> ()) {
        
        let body = item.toDict()
        
        api.update(nrSeq: nrSeq, body: body) { (success, message) in
            completion(success, message)
        }
        
    }
    
    public func update(nrSeq: Int, item: Item, image: UIImage, completion: @escaping (Bool, Bool, String, String) -> ()) {
        
        self.updateImage(nrSeq: nrSeq, image: image) { (imageSuccess, imageMessage) in
            
            self.update(nrSeq: nrSeq, item: item, completion: { (textSuccess, textMessage) in
                completion(imageSuccess, textSuccess, imageMessage, textMessage)
            })
            
        }
        
    }
    
    // MARK: - DELETE
    
    public func delete(nrSeq: Int, completion: @escaping (Bool, String) -> ()) {
        
        api.delete(nrSeq: nrSeq) { (success, message) in
            completion(success, message)
        }
        
    }
    
    // MARK: - Private functions
    
    private func itemsFrom(json: JSON?) -> [Item] {
        var items = [Item]()
        
        // try to create Item objects from json "items" list
        if let itemsList = json {
            
            for(index, _) in itemsList {
                
                if let i = Int(index) {
                    
                    let item = itemFrom(json: itemsList[i])
                    items.append(item)
                    
                }
            }
        }
        
        return items
    }
    
    private func itemFrom(json: JSON) -> Item {
        
        let item = Item()
        
        item.number = String(describing: json["NrPatrimonio"])
        item.name = String(describing: json["Nome"]).capitalized
        item.description = String(describing: json["Descricao"]).lowercased()
        
        item.nrSeq = Int(String(describing: json["NrSeqItem"]))
        
        item.userCanEdit = String(describing: json["Editar"]) == "TRUE"
        item.userCanRequest = String(describing: json["Solicitar"]) == "TRUE"
        
        if json["NomePessoaCadastro"] != JSON.null {
            let person = String(describing: json["NomePessoaCadastro"])
            item.personWhoRegistered = person
        }
        
        // orgao
        
        let orgao = Orgao()
        
        if json["NomeOrgao"] != JSON.null {
            orgao.name = String(describing: json["NomeOrgao"])
            orgao.initials = String(describing: json["SiglaOrgao"])
            orgao.code = String(describing: json["CodOrgao"])
        } else {
            orgao.name = String(describing: json["NomeOrgaoOrigem"])
            orgao.code = String(describing: json["CodOrgaoOrigem"])
        }
        
        item.sourceOrgao = orgao
        
        return item
    }
    
    private func getCompressionQuality(size: CGFloat) -> CGFloat {
        
        let imgLargeSize: CGFloat = 1000.0
        let imgHugeSize: CGFloat = 3000.0
        
        let maxCompressionQuality: CGFloat = 1.0
        let minCompressionQuality: CGFloat = 0.1
        
        var compression: CGFloat = maxCompressionQuality
        
        // 1001 +
        if size > imgLargeSize {
            
            // 4000 +
            if size >= imgHugeSize {
                compression = minCompressionQuality
                
                // 1001 ~ 2999
            } else {
                
                let ratio = (size - imgLargeSize) / (imgHugeSize - imgLargeSize)
                let diff = (maxCompressionQuality - minCompressionQuality) * ratio
                
                compression = maxCompressionQuality - diff
            }
        }
        
        return compression
    }
    
}

// MARK: - Create method to convert Data to Hex String

extension Data {
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    init?(fromHexEncodedString: String) {
        var str = fromHexEncodedString
        if str.count%2 != 0 {
            // insert 0 to get even number of chars
            str.insert("0", at: str.startIndex)
        }
        
        func decodeNibble(_ u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }
        
        let utf16 = str.utf16
        self.init(capacity: utf16.count/2)
        
        var i = utf16.startIndex
        while i != str.utf16.endIndex {
            guard let hi = decodeNibble(utf16[i]),
                let lo = decodeNibble(utf16[utf16.index(i, offsetBy: 1, limitedBy: utf16.endIndex)!]) else {
                    return nil
            }
            var value = hi << 4 + lo
            self.append(&value, count: 1)
            i = utf16.index(i, offsetBy: 2, limitedBy: utf16.endIndex)!
        }
    }
    
}
