//
//  StandardErrorTextView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 16/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class StandardErrorTextView: UIView{
    
    //MARK: - Properties
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .customSystemRed
        label.numberOfLines = 0
        return label
    }()
    

    //MARK: - Lifecåycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Helper functions
    
    private func configure(){
        addSubview(textLabel)
        textLabel.allSideConstraint(inView: self)
        
    }
}
