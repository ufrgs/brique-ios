//
//  CustomTabBarController.swift
//  ufrgs-mural
//
//  Created by Augusto on 18/03/2019.
//  Copyright © 2019 Augusto. All rights reserved.
//

import UIKit
import Hero

class  CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
    }
    
}

extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 59
        
        return sizeThatFits
    }
    
}
