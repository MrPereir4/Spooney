//
//  InfoBlockDisplayView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 01/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class InfoBlockDisplayView: UIView{
    //MARK: - Properties
    
    let holder = UIView()
    var mainStackHolder = UIStackView()
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    
    private let statusStack = UIStackView()
    
    
    private let statusLabel = UILabel()
    
    
    
    var totalBlockHeight = 0
    
    let icon = UIImageView(image: #imageLiteral(resourceName: "pencil"))
    
    var mainContentStackHolder = UIStackView()
    var subContentStackHolder = UIStackView()
    
    private var fullBlockHeight: CGFloat = 0
    
    private var title: String
    private var content: String
    private var subContent: [(String, String)]
    private var shouldHavePerc: Bool?
    private var percentValue: Int?
    private var percentTitle: String?
    private var shouldHaveStatus: Bool?
    private var status: Int?
    private var shouldHaveIcon: Bool?
    
    
    
    //MARK: - Lifecycle
    
    required init?(title: String, content: String, subContent: [(String, String)], shouldHavePerc: Bool? = true, percentTitle: String? = "", shouldHaveStatus: Bool? = false, status: Int? = 0, shouldHaveIcon: Bool? = false, percentValue: Int? = 0) {
        self.title = title
        self.content = content
        self.subContent = subContent
        self.shouldHavePerc = shouldHavePerc
        self.percentValue = percentValue
        self.percentTitle = percentTitle
        self.shouldHaveStatus = shouldHaveStatus
        self.status = status
        self.shouldHaveIcon = shouldHaveIcon
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    

    //MARK: - Helper functions
    
    private func configure(){
        configureUI()
    }
    
    private func configureUI(){
        backgroundColor = .white
        
        addSubview(holder)
        holder.allSideConstraint(inView: self, paddingY: 16, paddingX: 16)
        
        mainStackHolder.axis = .vertical
        mainStackHolder.spacing = 25
        
        
        
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 22)
        
        
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        
        mainContentStackHolder.addArrangedSubview(titleLabel)
        mainContentStackHolder.addArrangedSubview(contentLabel)
        mainContentStackHolder.axis = .vertical
        
        
        
        icon.isUserInteractionEnabled = true
        
        if shouldHaveIcon == true{
            icon.setDimensions(width: 55, height: 55)
            let headerStack = UIStackView(arrangedSubviews: [mainContentStackHolder, icon])
            mainStackHolder.addArrangedSubview(headerStack)
            
        }else{
            mainStackHolder.addArrangedSubview(mainContentStackHolder)
        }

        subContentStackHolder.axis = .vertical
        subContentStackHolder.spacing = 5


        for subCon in subContent{
            subContentStackHolder.addArrangedSubview(createSubContentView(title: subCon.0, content: subCon.1))
        }

        mainStackHolder.addArrangedSubview(subContentStackHolder)

        if shouldHaveStatus == true{
            let colorView = UIView()
            colorView.setDimensions(width: 20, height: 20)
            colorView.layer.cornerRadius = 10
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            
            statusStack.spacing = 5
            statusStack.axis = .horizontal
            //0 = green 1 = yellow 2 = red
            if status == 0{
                colorView.backgroundColor = .customSystemGreen
                titleLabel.text = "Health"
            }else if status == 1 || status == 2{
                colorView.backgroundColor = .customSystemYellow
                titleLabel.text = "Alert"
            }else{
                colorView.backgroundColor = .customSystemRed
                titleLabel.text = "Warning"
            }
            statusStack.addArrangedSubview(colorView)
            statusStack.addArrangedSubview(titleLabel)
            mainStackHolder.addArrangedSubview(statusStack)
            
            
            statusLabel.numberOfLines = 2
            statusLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            switch status{
            case 1:
                statusLabel.text = "Insufficient salary to pay the bills"
                mainStackHolder.addArrangedSubview(statusLabel)
            case 2:
                statusLabel.text = "Used more than 50% of salary"
                mainStackHolder.addArrangedSubview(statusLabel)
            case 3:
                statusLabel.text = "Insufficient equity and salary to pay the bills"
                mainStackHolder.addArrangedSubview(statusLabel)
            default:
                statusLabel.removeFromSuperview()
            }
            
            
            

            statusStack.layoutIfNeeded()
            fullBlockHeight += statusStack.frame.size.height + 25
            print(fullBlockHeight)
        }
        
        if shouldHavePerc == true{
            let percentageImpactView = CircleBarView(percent: percentValue!)
            percentageImpactView.configure()
            percentageImpactView.animateView()
            
            holder.addSubview(percentageImpactView)
            percentageImpactView.anchor(top: holder.topAnchor, right: holder.rightAnchor, paddingTop: 28, paddingRight: 28)
        }

        holder.addSubview(mainStackHolder)
        mainStackHolder.anchor(top: holder.topAnchor, right: holder.rightAnchor, left: holder.leftAnchor)
    }

    private func createSubContentView(title: String, content: String) -> UIStackView{
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .overContentGray

        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        contentLabel.textColor = .overContentGray
        
        let stack = UIStackView()
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(contentLabel)
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }
}
