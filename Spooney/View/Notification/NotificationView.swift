//
//  NotificationView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 15/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    //MARK: - Properties
    let holder = UIView()
    let textContent = UILabel()
    var type: Int = 0
    var view: UIView?
    var bgColor: UIColor?
    //MARK: - Lifecycle
    //0 = goal 1 = bill 2 = instant
    required init?(type: Int, view: UIView, color: UIColor? = .customSystemGreen) {
        self.type = type
        self.view = view
        self.bgColor = color
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector

    //MARK: - Helper functions
    
    func configureUI(){
        addSubview(holder)
        holder.layer.cornerRadius = 20
        holder.frame = CGRect(x: 75, y: -40, width: view!.frame.width - 150, height: 40)
        holder.backgroundColor = bgColor
        
        
        textContent.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        textContent.textColor = .white
        if type == 0{
            textContent.text = "Goal added"
        }else if type == 1{
            textContent.text = "Bill added"
        }else if type == 3{
            textContent.text = "Instant bill added"
        }else{}
        
        holder.addSubview(textContent)
        textContent.centerX(inView: holder)
        textContent.centerY(inView: holder)
        
    }
}
