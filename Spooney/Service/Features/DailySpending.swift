//
//  DailySpending.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 05/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

func calculateDailySpending(totalBillSpends: Int, totalGoalSpends: Int, monthIncome: Int) -> Int{
    //Calculating how many days are in a month
    let calendar = Calendar.current
    let components = DateComponents(day: 1)
    let startOfNextMonth = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
    let lastDayDate = calendar.date(byAdding: .day, value: -1, to: startOfNextMonth)!
    let cal = Calendar.current
    let dayCompon = cal.component(.day, from: lastDayDate)
    
    let dailySpendsInt: Int = (monthIncome - (totalBillSpends + totalGoalSpends)) / dayCompon
    return dailySpendsInt
}
