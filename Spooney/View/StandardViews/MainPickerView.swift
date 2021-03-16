//
//  MainPickerView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class MainPickerView: UIView{
    //MARK: - Properties
    
    lazy var tf: UITextField = {
        let tf = UITextField()
        tf.placeholder = title
        tf.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        tf.autocorrectionType = .no
        tf.keyboardType = keyboardType!
        return tf
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.textColor = .placeholderGray
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        return label
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = headerString
        label.textColor = .overContentGray
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    lazy var segControl: UISegmentedControl = {
        let segCon = UISegmentedControl(items: segControlItems)
        segCon.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 17)
        segCon.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        return segCon
    }()
    
    private var title: String?
    private var isTextField: Bool?
    private var isSegmentedControl: Bool?
    private var segControlItems: [String]?
    private var keyboardType: UIKeyboardType?
    private var shouldHaveHeader: Bool?
    private var headerString: String?
    //MARK: - Lifecycle
    
    required init(title: String? = "", isTextField: Bool? = true, isSegmentedControl: Bool? = false, segControlItems: [String]? = [], keyboardType: UIKeyboardType? = .default, shouldHaveHeader: Bool? = false, headerString: String? = "") {
        self.title = title
        self.isTextField = isTextField
        self.isSegmentedControl = isSegmentedControl
        self.segControlItems = segControlItems
        self.keyboardType = keyboardType
        self.shouldHaveHeader = shouldHaveHeader
        self.headerString = headerString
        super.init(frame: CGRect.zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper functions
    
    private func configureUI(){
        
        
        
        if shouldHaveHeader == true{
            let stack: UIStackView
            
            if isTextField == true{
                stack = UIStackView(arrangedSubviews: [headerLabel, tf])
                
            }else{
                
                
                if isSegmentedControl == true{
                    stack = UIStackView(arrangedSubviews: [headerLabel, segControl])
                    segControl.anchor(right: stack.rightAnchor, left: stack.leftAnchor, height: 35)
                }else{
                    stack = UIStackView(arrangedSubviews: [headerLabel, titleLabel])
                }
            }
            
            stack.axis = .vertical
            stack.alignment = .leading
            stack.spacing = 0
            
            addSubview(stack)
            
            stack.allSideConstraint(inView: self)
            
        }else{
            
            if isTextField == true{
                addSubview(tf)
                tf.allSideConstraint(inView: self)
            }else{
                addSubview(titleLabel)
                titleLabel.allSideConstraint(inView: self)
            }
        }
    }
}
