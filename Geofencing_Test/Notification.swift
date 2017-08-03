//
//  Notification.swift
//  Geofencing_Test
//
//  Created by Ryan Harri on 2017-07-18.
//  Copyright © 2017 Ryan Harri. All rights reserved.
//

import Foundation

struct Notification {
    var id: UUID
    var radius: Int
    var message: String
    
    init(radius: Int, message: String) {
        self.id = UUID(uuidString: NSUUID().uuidString)!
        self.radius = radius
        self.message = message
    }
    
    init?(radius: String, message: String) {
        guard let r = Int(radius) else {
            return nil
        }
        
        self.id = UUID(uuidString: NSUUID().uuidString)!
        self.radius = r
        self.message = message
    }
}
