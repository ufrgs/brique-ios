//
//  CustomImagePickerController.swift
//  ufrgs-mural
//
//  Created by Augusto on 29/11/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation
import UIKit

class CustomImagePickerController: UIImagePickerController {
    
    var completionHandler: ((UIImage?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavBar()
//        self.setNavigationBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configure(type: UIImagePickerControllerSourceType) {
        self.allowsEditing = false
        self.sourceType = type
        self.mediaTypes = UIImagePickerController.availableMediaTypes(for: type)!
    }
    private func configureNavBar() {
        self.navigationBar.tintColor = .white
        self.navigationBar.barTintColor = Helper.appColor
        self.navigationBar.isTranslucent = false
        
        if let font = UIFont(name: "AvenirNext-Demibold", size: 18) {
            self.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : UIColor.white,
            ]
        }
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        let height = UIApplication.shared.statusBarFrame.height + 44
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: height))
        let navItem = UINavigationItem(title: "Fotos")
        
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: nil, action: #selector(cancel))
        
        if let font = UIFont(name: "AvenirNext-Regular", size: 17) {
            cancelButton.setTitleTextAttributes([
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : UIColor.black,
                ], for: .normal)
        }
        
        navItem.leftBarButtonItem = cancelButton
        navBar.setItems([navItem], animated: false)
        
        self.view.addSubview(navBar)
    }

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
