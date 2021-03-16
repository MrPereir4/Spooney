//
//  LoadingFullSizeView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 16/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit


class LoadingFullSizeView: UIView{
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Helper functions
    func configureUI(){
        let darkBg = UIView()
        addSubview(darkBg)
        darkBg.allSideConstraint(inView: self)
        
        darkBg.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.color = .white
        let textLabel = UILabel()
        textLabel.text = "Sending..."
        textLabel.font = UIFont.systemFont(ofSize: 17)
        textLabel.textColor = .white
        
        let stack = UIStackView(arrangedSubviews: [activityIndicator, textLabel])
        stack.spacing = 5
        stack.axis = .horizontal
        darkBg.addSubview(stack)
        stack.centerX(inView: darkBg)
        stack.centerY(inView: darkBg)
        
    }
}
