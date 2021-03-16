//
//  ViewsListWithHeaderView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 30/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class ViewsListWithHeaderView: UIView{
    
    //MARK: - Properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    var mainTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        return table
    }()
    
    let title: String
    
    //MARK: - Lifecycle
    
    required init?(title: String) {
        self.title = title
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
        let holder = UIView()
        addSubview(holder)
        holder.allSideConstraint(inView: self)
        
        holder.addSubview(titleLabel)
        titleLabel.anchor(top: holder.topAnchor, right: holder.rightAnchor, left: holder.leftAnchor)
        
        holder.addSubview(mainTableView)
        mainTableView.anchor(top: titleLabel.bottomAnchor, right: holder.rightAnchor, bottom: holder.bottomAnchor, left: holder.leftAnchor, paddingTop: 5)
        
    }
    
}
