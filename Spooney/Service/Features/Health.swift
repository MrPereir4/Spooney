//
//  Health.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import Foundation
import Firebase


private func isBetween(_ date1: Date, and date2: Date, dateToCompare: Date) -> Bool {
    return (min(date1, date2) ... max(date1, date2)).contains(dateToCompare)
}

private func returningValueOfBillInMonth(uid: String, incomeSalaryDate: Int, completion: @escaping(Int) -> Void){
    
    var totalPrice: Int = 0
    
    let actualDate = Date()
    let actualCalendar = Calendar.current
    let actualComponents = actualCalendar.dateComponents([.year, .month, .day], from: actualDate)
    let actualDay = actualComponents.day!
    let actualMonth: Int = actualComponents.month!
    let actualYear = actualComponents.year!
    
    let fromStringDate = "\(actualYear)-\(actualMonth)-\(incomeSalaryDate)"
    var toStringDate: String = ""
    if actualMonth < 12{
        toStringDate = "\(actualYear)-\(actualMonth + 1)-\(incomeSalaryDate)"
    }else{
        toStringDate = "\(actualYear + 1)-1-\(incomeSalaryDate)"
    }
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let fromDate = dateFormatter.date(from: fromStringDate)
    let toDate = dateFormatter.date(from: toStringDate)
    
    BillService.shared.fetchBill(uid: uid) { (snapshot) in
        for child in snapshot.children.allObjects as! [DataSnapshot]{
            let dict = child.value as? [String: Any] ?? [:]
            let price = dict["price"] as! String
            let billingDate = dict["billingDate"] as! String
            let repetition = dict["repetition"] as! Int
            
            var convertedDate = ""
            
            //arrumar o tipo
            if repetition == 0{
                if Int(billingDate)! > actualDay{
                    convertedDate = "\(actualYear)-\(actualMonth)-\(billingDate)"
                }else{
                    let nextMonth: Int
                    if actualMonth == 12{
                        nextMonth = 1
                        convertedDate = "\(actualYear + 1)-\(nextMonth)-\(billingDate)"
                    }else{
                        nextMonth = actualMonth + 1
                        convertedDate = "\(actualYear)-\(nextMonth)-\(billingDate)"
                    }
                }
            }else{
                convertedDate = billingDate
            }
            
            let billDate = dateFormatter.date(from: convertedDate)
            
            
            if isBetween(fromDate!, and: toDate!, dateToCompare: billDate!){
                
                totalPrice += Int(price)!
            }
        }
        
        UserService.shared.fetchUserGoals(uid: uid) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                let dict = child.value as? [String: Any] ?? [:]
                let installPrice = dict["installment"] as! String
                
                totalPrice += Int(installPrice)!
            }
            
            completion(totalPrice)
        }
    }
    
    
}


func comparingValues(incomeSalaryDate: Int, userIncome: Int, userSalary: Int, completion: @escaping(Int) -> Void){
    //0 = green 1 = yellow(used 100% of salary) 2 = yellow(used 50% of salary) 3 = red(Total equity insuficient)
    var indicatorInt = 0
    guard let uid = Auth.auth().currentUser?.uid else {return}
    
    
    returningValueOfBillInMonth(uid: uid, incomeSalaryDate: incomeSalaryDate) { (fullValue) in
        let percentegeOfSalary = (Float(fullValue)/Float(userSalary)) * 100
        let percentegeOfTotalBalance = (Float(fullValue)/Float(userIncome)) * 100
        
        
        if percentegeOfSalary >= 100.0{
            if percentegeOfTotalBalance >= 100.0{
                indicatorInt = 3
            }else{
                indicatorInt = 1
            }
            
        }else if percentegeOfSalary > 50{
            indicatorInt = 2
        }
        completion(indicatorInt)
    }
    
}
