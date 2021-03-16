//
//  ContentDisplayBlock.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 30/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class ContentDisplayBlock: UITableViewCell{
    
    //MARK: - Properties
    let holder = UIView()

    var title: String = String()
    var content: String = String()
    var subContent: String = String()
    var percentage: Int = Int()
    var isWhiteBack: Bool = false
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector

    //MARK: - Helper functions
    
    func configureUI(){
        
        holder.backgroundColor = .white
        if isWhiteBack == true{
            holder.backgroundColor = .grayBack
        }
        holder.layer.cornerRadius = 12
        addSubview(holder)
        holder.allSideConstraint(inView: self)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        let subContentLabel = UILabel()
        subContentLabel.text = subContent
        subContentLabel.font = UIFont.systemFont(ofSize: 17)
        subContentLabel.textColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, subContentLabel])
        stack.axis = .vertical
        stack.spacing = 0
        
        holder.addSubview(stack)
        
        stack.anchor(top: holder.topAnchor, bottom: holder.bottomAnchor, left: holder.leftAnchor, paddingTop: 8, paddingBottom: 8, paddingLeft: 8)
        
    }
    
}
