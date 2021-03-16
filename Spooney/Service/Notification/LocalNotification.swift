//
//  LocalNotification.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 03/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import UserNotifications

func displayNotification(title: String, body: String) -> UNNotificationRequest{
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    var dateComponents = DateComponents()
    dateComponents.hour = 09
    dateComponents.minute = 00
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
    return request
}
