//
//  TotalEquityFeatures.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 05/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit


func calculateForecastForNextMonth(totalEquity: Int, monthIncoming: Int, totalBill: Int, totalGoal: Int) -> Int{
    let forecast = (totalEquity + monthIncoming) - (totalBill + totalGoal)
    return forecast
}
