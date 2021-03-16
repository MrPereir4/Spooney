//
//  Bill.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 08/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import Foundation

struct Bill{
    let name: String
    let price: String
    let repetition: Int
    let billingDate: String
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String ?? ""
        self.price = dictionary["price"] as? String ?? ""
        self.repetition = dictionary["repetition"] as? Int ?? 0
        self.billingDate = dictionary["billingDate"] as? String ?? ""
    }
}

struct InstantBill{
    let name: String
    let category: Int
    let price: String
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String ?? ""
        self.category = dictionary["category"] as? Int ?? 0
        self.price = dictionary["price"] as? String ?? ""
    }
}
