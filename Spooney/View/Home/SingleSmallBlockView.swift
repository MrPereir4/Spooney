//
//  SingleSmallBlockView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 30/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class SingleSmallBlockView: UIView{
    
    //MARK: - Properties
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = content
        return label
    }()
    
    var percentValueInt: Int = 0
    
    var contentBlock = UIView()
    var contentButton = UIButton()

    //MARK: - Lifecycle
    
    private var isButton: Bool?
    private var title: String
    private var backColor: UIColor?
    private var content: String?
    private var shouldHavePercent: Bool?
    
    required init?(isButton: Bool? = false, title: String, backColor: UIColor? = .white, content: String? = "", shouldHavePercent: Bool? = false) {
        self.isButton = isButton
        self.title = title
        self.backColor = backColor
        self.content = content
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
        contentBlock.removeFromSuperview()
        contentButton.removeFromSuperview()
        
        
        
        if isButton == true{
            guard let backColor = backColor else {return}
            contentButton = blockIsButton(title: title, backColor: backColor)
            addSubview(contentButton)
            contentButton.allSideConstraint(inView: self)
        }else{
            guard let content = content else {return}
            contentBlock = blockWithContent(title: title, content: content)
            addSubview(contentBlock)
            contentBlock.allSideConstraint(inView: self)
            
            if shouldHavePercent == true{
                let percentView = CircleBarView(percent: percentValueInt)
                percentView.configure()
                percentView.animateView()
                contentBlock.addSubview(percentView)
                percentView.anchor(right: contentBlock.rightAnchor, paddingRight: 40)
                percentView.centerY(inView: contentBlock)
            }
        }
        
        
        
        
        
    }
    
    private func blockWithContent(title: String, content: String) -> UIView {
        let holder = UIView()
        holder.backgroundColor = backColor
        holder.layer.cornerRadius = 12
        addSubview(holder)
        holder.allSideConstraint(inView: self)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.axis = .vertical
        
        holder.addSubview(stack)
        stack.anchor(top: holder.topAnchor, left: holder.leftAnchor, paddingTop: 8, paddingLeft: 8)
        return holder
    }
    
    private func blockIsButton(title: String, backColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backColor
        return button
    }
}
