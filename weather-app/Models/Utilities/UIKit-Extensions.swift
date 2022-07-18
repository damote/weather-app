//
//  UIKit-Extensions.swift
//  weather-app
//
//  Created by Dustin Mote on 7/16/22.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    
    func activate() {
        self.isActive = true
    }
}


extension DateFormatter {
    
    static var ISO8601dateFormatter: ISO8601DateFormatter {
        
        let formatter = ISO8601DateFormatter()
        return formatter
    }
    
    
    static var shortDayDateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}


