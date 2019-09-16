//
//  Helper.swift
//  ufrgs-mural
//
//  Created by Augusto on 27/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftOverlays
import UIKit

class Helper {
    
    static let appColor = UIColor(red: 51/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
    
    // MARK: - UIAlert methods
    
    static func createSimpleAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        return alert
    }
    
    static func createAlertWithTextInput(title: String, message: String?, defaultText: String?, okButtonTitle: String, completion: @escaping (String?) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = defaultText
        }
        
        let ok = UIAlertAction(title: okButtonTitle, style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                completion(textField.text)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        return alert
    }
    
    // MARK: - Internet methods
    
    static func internetIsConnected() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    // MARK: - String methods
    
    static func isValid(string: String?) -> Bool {
        if string == nil {
            return false
        }
        return !(string!.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    static func parseString(original: String) -> String {
        var result = original.folding(options: .diacriticInsensitive, locale: NSLocale.current)
        
        if let spacesTrimmed = result.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            result = spacesTrimmed
        }
        
        return result
    }
    
    static func toast(message: String, time: Double, view: UIView?, completion: (() -> ())?) {
        if let superview = view {
            SwiftOverlays.showTextOverlay(superview, text: message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                SwiftOverlays.removeAllOverlaysFromView(superview)
                if let c = completion {
                    c()
                }
            }
        } else {
            if let c = completion {
                c()
            }
        }
    }
    
    // MARK: - Table View stuff methods
    
    static func createSpinner(width: CGFloat) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: width, height: CGFloat(44))
        
        return spinner
    }
    
    static func create1pxHeader(width: CGFloat) -> UIView {
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: width, height: CGFloat(1))
        let view = UIView(frame: frame)
        
        view.backgroundColor = .clear
        
        return view
    }
    
    // MARK: - UIAlert methods
    
    static func createNoInternetAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: "Erro de conexão", message: "O dispositivo parece estar desconectado da internet.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        return alert
        
    }
    
}
