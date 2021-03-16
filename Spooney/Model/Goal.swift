//
//  Goal.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 06/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import Foundation

struct Goal {
    let name: String
    let price: String
    let priority: Int
    let type: String
    let expDate: String
    let monInstallment: String
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String ?? ""
        self.price = dictionary["price"] as? String ?? ""
        self.priority = dictionary["priority"] as? Int ?? 0
        self.type = dictionary["type"] as? String ?? ""
        self.expDate = dictionary["expDate"] as? String ?? ""
        self.monInstallment = dictionary["installment"] as? String ?? ""
        
    }
}
