//
//  WelcomeViewCell.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 26/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class WelcomeViewCell: UICollectionViewCell{
    //MARK: - Properties
    
    let title: UILabel = {
        let label = UILabel()
        label.text = "teste"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    let about: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Spooney, your new \n platform to control your spendings!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    let pageController: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 3
        return pc
    }()
    
    
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Helper function
    
    private func configure(){
        backgroundColor = .white
        configureContent()
    }
    
    private func configureContent(){
        
        addSubview(about)
        about.anchor(right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, paddingRight: 16, paddingBottom: 25, paddingLeft: 16)
        
        addSubview(title)
        title.anchor(right: rightAnchor, bottom: about.topAnchor, left: leftAnchor, paddingRight: 16, paddingBottom: 20, paddingLeft: 16)
    }
    
}
