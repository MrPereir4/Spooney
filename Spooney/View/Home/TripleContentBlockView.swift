//
//  TripleContentBlockView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 30/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit


class TripleContentBlockView: UIView{
    
    //MARK: - Properties
    
    let mainHolder = UIView()
    
    var mainStackHolder: UIStackView?
    
    var topLeftContainer = UIView()
    var bottomLeftContainer = UIView()
    var rightContentHolder = UIView()
    
    var topLeftValue = String()
    var bottomLeftValue = String()
    var rightValue = String()
    
    var percentValueInt: Int = 0

    private var topLeftIsButton: Bool?
    private var topLeftBlock: String
    private var bottomLeftIsButton: Bool?
    private var bottomLeftBlock: String
    private var rightIsButton: Bool?
    private var rightBlock: String
    private var buttonColor: [UIColor]?
    private var rightIsBiggerText: Bool?
    private var shouldHavePercent: Bool?
    
    
    //MARK: - Lifecycle
    
    required init?(topLeftIsButton: Bool? = false, topLeftBlock: String, bottomLeftIsButton: Bool? = false, bottomLeftBlock: String, rightIsButton: Bool? = false, rightBlock: String, buttonColor: [UIColor]? = [.white, .white, .white], rightIsBiggerText: Bool? = false, shouldHavePercent: Bool? = false) {
        self.topLeftIsButton = topLeftIsButton
        self.topLeftBlock = topLeftBlock
        self.bottomLeftIsButton = bottomLeftIsButton
        self.bottomLeftBlock = bottomLeftBlock
        self.rightIsButton = rightIsButton
        self.rightBlock = rightBlock
        self.buttonColor = buttonColor
        self.rightIsBiggerText = rightIsBiggerText
        self.shouldHavePercent = shouldHavePercent
        super.init(frame: CGRect.zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selector
    
    
    

    //MARK: - Helper functions
    
    func configureUI(){
        
        addSubview(mainHolder)
        mainHolder.allSideConstraint(inView: self)  
        contentUpdate()
    }
    
    
    func contentUpdate(){
        
        mainStackHolder?.removeFromSuperview()
        
        if topLeftIsButton == true{
            topLeftContainer = contentBlockButton(title: topLeftBlock, backColor: buttonColor![0])
        }else{
            topLeftContainer = contentBlock(title: topLeftBlock, content: topLeftValue, contentColor: .customSystemGreen)
        }
        
        if bottomLeftIsButton == true{
            bottomLeftContainer = contentBlockButton(title: bottomLeftBlock, backColor: buttonColor![1])
        }else{
            bottomLeftContainer = contentBlock(title: bottomLeftBlock, content: bottomLeftValue, contentColor: .customSystemRed)
        }
        
        if rightIsButton == true{
            rightContentHolder = contentBlockButton(title: rightBlock, backColor: buttonColor![2])
        }else{
            rightContentHolder = contentBlock(title: rightBlock, content: rightValue, shouldHavePercent: shouldHavePercent!)
        }
        
        let leftStackHolder =  UIStackView(arrangedSubviews: [topLeftContainer, bottomLeftContainer])
        leftStackHolder.axis = .vertical
        leftStackHolder.spacing = 16
        leftStackHolder.distribution = .fillEqually

        

        mainStackHolder =  UIStackView(arrangedSubviews: [leftStackHolder, rightContentHolder])
        mainStackHolder!.axis = .horizontal
        mainStackHolder!.spacing = 16
        mainStackHolder!.distribution = .fillEqually
        
        mainHolder.addSubview(mainStackHolder!)
        mainStackHolder!.allSideConstraint(inView: mainHolder)
    }
    
    
    func contentBlock(title: String, content: String, contentColor: UIColor? = .black, rightBlockShouldHaveMoreInfo: Bool? = false, shouldHavePercent: Bool = false) -> UIView{
        
        let block = UIView()
        block.backgroundColor = .white
        block.layer.cornerRadius = 12
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = title
        
        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        if rightIsBiggerText == true{
            contentLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        }
        contentLabel.text = content
        contentLabel.textColor = contentColor
        
        
        
        let stackHolder = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackHolder.axis = .vertical
        stackHolder.spacing = 0
        
        block.addSubview(stackHolder)
        stackHolder.anchor(top: block.topAnchor, right: block.rightAnchor, left: block.leftAnchor, paddingTop: 8, paddingRight: 8, paddingLeft: 8)
        
        if shouldHavePercent == true{
            var percentView = CircleBarView(percent: percentValueInt)
            percentView.configure()
            percentView.animateView()
            block.addSubview(percentView)
            percentView.anchor(right: block.rightAnchor, bottom: block.bottomAnchor, paddingRight: 40, paddingBottom: 40)
        }
        
        return block
    }
    
    func contentBlockButton(title: String, backColor: UIColor) -> UIButton{
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backColor
        return button
    }
    
}
