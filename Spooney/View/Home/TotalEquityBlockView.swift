//
//  TotalEquityBlockView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 29/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class TotalEquityBlockView: UIView{
    
    //MARK: - Properties
    
    let holder = UIView()
    let titleLabel = UILabel()
    
    lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.text = totalValue
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    //2 = red, 1 = yellow, 1 = green
    private lazy var barView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .lightGray
        return label
    }()
    
    private var totalValue: String
    private var lastUpdate: String
    var statusColor: Int = 0

    //MARK: - Lifecycle
    
    required init(totalValue: String, lastUpdate: String) {
        self.totalValue = totalValue
        self.lastUpdate = lastUpdate
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector

    //MARK: - Helper functions
    
    func configureUI(){
        holder.removeFromSuperview()
        
        holder.backgroundColor = .white
        holder.layer.cornerRadius = 12
        
        addSubview(holder)
        holder.allSideConstraint(inView: self)
        
        holder.addSubview(barView)
        barView.anchor(top: holder.topAnchor, right: holder.rightAnchor, bottom: holder.bottomAnchor, paddingTop: 8, paddingRight: 8, paddingBottom: 8, width: 10)
        
        if statusColor == 0{
            barView.backgroundColor = .customSystemGreen
        }else if statusColor == 1{
            barView.backgroundColor = .customSystemYellow
        }else if statusColor == 2{
            barView.backgroundColor = .customSystemYellow
        }else{
            barView.backgroundColor = .customSystemRed
        }
        
        titleLabel.text = "Total equity"
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, totalValueLabel])
        stack.axis = .vertical
        stack.spacing = 0
        
        let fullHeaderStack = UIStackView()
        fullHeaderStack.axis = .horizontal
        
        holder.addSubview(stack)
        
        stack.anchor(top: holder.topAnchor, right: barView.leftAnchor, left: holder.leftAnchor, paddingTop: 8, paddingRight: 8, paddingBottom: 8, paddingLeft: 8)
        
        lastUpdatedLabel.text = "Last updated: " + lastUpdate
        
        holder.addSubview(lastUpdatedLabel)
        lastUpdatedLabel.anchor(bottom: holder.bottomAnchor, left: holder.leftAnchor, paddingBottom: 8, paddingLeft: 8)
        
        
    }
}
