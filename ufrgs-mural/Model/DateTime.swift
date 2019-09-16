//
//  Date.swift
//  ufrgs-alerta
//
//  Created by Augusto on 18/09/2018.
//  Copyright © 2018 Augusto. All rights reserved.
//

import Foundation

class DateTime: NSObject {
    
    // date
    var year: Int = -1
    var month: Int = -1
    var day: Int = -1
    
    // time
    var hour: Int = -1
    var minute: Int = -1
    var second: Int = -1
    
    init(aDay: Int, aMonth: Int, aYear: Int, anHour: Int, aMinute: Int, aSecond: Int) {
        self.year = aYear
        self.month = aMonth
        self.day = aDay
        
        self.hour = anHour
        self.minute = aMinute
        self.second = aSecond
    }
    
    override init() {
        super.init()
        self.now()
    }
    
    func now() {
        let date = Date()
        let calendar = Calendar.current
        
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
        
        self.hour = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
        self.second = calendar.component(.second, from: date)
    }
}
