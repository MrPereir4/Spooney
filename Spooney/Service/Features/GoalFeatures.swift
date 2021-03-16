//
//  GoalFeatures.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 05/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import Firebase

func calculateDaysLeftToExpDate(expDateString: String) -> Int{
    let actualDate = Date()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let expDate = dateFormatter.date(from: expDateString) else {return 0}
    
    let monthsBetween = Calendar.current.dateComponents([.month], from: actualDate, to: expDate).month!
    
    return monthsBetween
}


func calculateMonthInstallment(percentageAvaliable: Int, userMntIncome: Int, goalPriority: Int, allGoals: [Int]) -> Int{
    var numberOfPriorityLvl1 = 0
    var numberOfPriorityLvl2 = 0
    var numberOfPriorityLvl3 = 0
    
    switch goalPriority {
    case 0:
        numberOfPriorityLvl1 += 1
    case 1:
        numberOfPriorityLvl2 += 1
    case 2:
        numberOfPriorityLvl3 += 1
    default:
        return 0
    }
    
    
    let userMntIncomeAvaliableFloat = Float(userMntIncome) * (Float(percentageAvaliable) / 100)
    let userMntIncomeAvaliable = Int(userMntIncomeAvaliableFloat)
    
    if allGoals.count > 0{
        for sGoal in allGoals {
            if sGoal == 0{
                numberOfPriorityLvl1 += 1
            }else if sGoal == 1{
                numberOfPriorityLvl2 += 1
            }else if sGoal == 2{
                numberOfPriorityLvl3 += 1
            }
        }
        
        

        if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 == 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl1
            return newValue
        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 == 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl2
            return newValue
        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 > 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl3
            return newValue
        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 == 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/3)) / Float(numberOfPriorityLvl1)
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/3)) / Float(numberOfPriorityLvl2)
            
            if goalPriority == 0{
                return Int(valueForLvl1)
            }else{
                return Int(valueForLvl2)
            }
            
        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/4)) / Float(numberOfPriorityLvl1)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/4)) / Float(numberOfPriorityLvl3)

            if goalPriority == 0{
                return Int(valueForLvl1)
            }else{
                return Int(valueForLvl3)
            }
        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/5)) / Float(numberOfPriorityLvl2)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/5)) / Float(numberOfPriorityLvl3)

            if goalPriority == 1{
                return Int(valueForLvl2)
            }else{
                return Int(valueForLvl3)
            }
        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/6)) / Float(numberOfPriorityLvl2)
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/6)) / Float(numberOfPriorityLvl2)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/6)) / Float(numberOfPriorityLvl3)

            if goalPriority == 0{
                return Int(valueForLvl1)
            }else if goalPriority == 1{
                return Int(valueForLvl2)
            }else{
                return Int(valueForLvl3)
            }
        }
    }else{
        return userMntIncomeAvaliable
    }
    return 0
}


func updateAllGoalsToNewValues(percentageAvaliable: Int, userMntIncome: Int, allGoals: [(Int, Int, String)], completion: @escaping() -> Void){
    var numberOfPriorityLvl1 = 0
    var lvl1PrioGoals = [(Int, Int, String)]()
    var numberOfPriorityLvl2 = 0
    var lvl2PrioGoals = [(Int, Int, String)]()
    var numberOfPriorityLvl3 = 0
    var lvl3PrioGoals = [(Int, Int, String)]()
    
    let userMntIncomeAvaliableFloat = Float(userMntIncome) * (Float(percentageAvaliable) / 100)
    let userMntIncomeAvaliable = Int(userMntIncomeAvaliableFloat)
    
    if allGoals.count > 0{
        for sGoal in allGoals {
            if sGoal.0 == 0{
                numberOfPriorityLvl1 += 1
                lvl1PrioGoals.append(sGoal)
            }else if sGoal.0 == 1{
                numberOfPriorityLvl2 += 1
                lvl2PrioGoals.append(sGoal)
            }else if sGoal.0 == 2{
                numberOfPriorityLvl3 += 1
                lvl3PrioGoals.append(sGoal)
            }
        }
        
        
        if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 == 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl1
            for sGoal in lvl1PrioGoals{
                if sGoal.1 != newValue {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: newValue) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 == 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl2
            for sGoal in lvl2PrioGoals{
                if sGoal.1 != newValue {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: newValue) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 > 0{
            let newValue = userMntIncomeAvaliable / numberOfPriorityLvl3
            for sGoal in lvl3PrioGoals{
                if sGoal.1 != newValue {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: newValue) { () in
                       print("ok")
                        completion()
                    }
                }
            }
        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 == 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/3)) / Float(numberOfPriorityLvl1)
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/3)) / Float(numberOfPriorityLvl2)
            
            for sGoal in lvl1PrioGoals{
                if sGoal.1 != Int(valueForLvl1) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl1)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
            for sGoal in lvl2PrioGoals{
                if sGoal.1 != Int(valueForLvl2) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl2)) { () in
                        print("ok")
                        completion()
                    }
                }
            }

        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 == 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/4)) / Float(numberOfPriorityLvl1)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/4)) / Float(numberOfPriorityLvl3)
            
            for sGoal in lvl1PrioGoals{
                if sGoal.1 != Int(valueForLvl1) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl1)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
            for sGoal in lvl3PrioGoals{
                if sGoal.1 != Int(valueForLvl3) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl3)) { () in
                        print("ok")
                        completion()
                    }
                }
            }

        }else if numberOfPriorityLvl1 == 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/5)) / Float(numberOfPriorityLvl2)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/5)) / Float(numberOfPriorityLvl3)
            
            for sGoal in lvl2PrioGoals{
                if sGoal.1 != Int(valueForLvl2) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl2)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
            for sGoal in lvl3PrioGoals{
                if sGoal.1 != Int(valueForLvl3) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl3)) { () in
                        print("ok")
                        completion()
                    }
                }
            }


        }else if numberOfPriorityLvl1 > 0 && numberOfPriorityLvl2 > 0 && numberOfPriorityLvl3 > 0{
            let valueForLvl1 = (Float(userMntIncomeAvaliable) * (1/6)) / Float(numberOfPriorityLvl1)
            let valueForLvl2 = (Float(userMntIncomeAvaliable) * (2/6)) / Float(numberOfPriorityLvl2)
            let valueForLvl3 = (Float(userMntIncomeAvaliable) * (3/6)) / Float(numberOfPriorityLvl3)

            for sGoal in lvl1PrioGoals{
                if sGoal.1 != Int(valueForLvl1) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl1)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
            for sGoal in lvl2PrioGoals{
                if sGoal.1 != Int(valueForLvl2) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl2)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
            
            for sGoal in lvl3PrioGoals{
                if sGoal.1 != Int(valueForLvl3) {
                    GoalService.shared.updateGoalValue(uid: sGoal.2, newValue: Int(valueForLvl3)) { () in
                        print("ok")
                        completion()
                    }
                }
            }
        }
    }else{
        completion()
    }
}
