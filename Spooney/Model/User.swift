//
//  User.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 06/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import Foundation

struct User {
    var firstName: String
    var lastName: String
    var monthIncome: String
    var incomeDate: String
    var totalEquity: String
    var uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.monthIncome = dictionary["monthIncome"] as? String ?? ""
        self.incomeDate = dictionary["incomeDate"] as? String ?? ""
        self.totalEquity = dictionary["totalEquity"] as? String ?? ""
    }
    
}
