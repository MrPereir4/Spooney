//
//  Extensions.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 26/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

extension UIColor{
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor{
        return UIColor.init(displayP3Red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let placeholderGray = rgb(196, 196, 198)
    static let overContentGray = rgb(149, 149, 153)
    static let darkerBackground = rgb(239, 239, 244)
    static let grayBack = rgb(242, 242, 247)
    static let ultraLightGray = rgb(244, 244, 244)
    static let pinkRed = rgb(255, 45, 85)
    
    static let customSystemBlue = rgb(0, 122, 255)
    static let customSystemGreen = rgb(52, 199, 89)
    static let customSystemRed = rgb(255, 59, 48)
    static let customSystemYellow = rgb(255, 204, 0)
    
    
    
    
    static let animationLightColor = rgb(229, 229, 229)
    
}

extension UIView{
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingRight: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil
                ){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let left = left{
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let width = width{
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height{
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setDimensions(width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func centerX(inView view: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func allSideConstraint(inView view: UIView, paddingY: CGFloat = 0, paddingX: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        
        
        
        anchor(top: view.topAnchor,
               right: view.rightAnchor,
               bottom: view.bottomAnchor,
               left: view.leftAnchor,
               paddingTop: paddingY,
               paddingRight: paddingX,
               paddingBottom: paddingY,
               paddingLeft: paddingX)
        
    }
    
    func loadingBlock(view: UIView, width: CGFloat, height: CGFloat, paddinLeft: CGFloat? = 16) -> UIView{
        let sigleBlock = UIView()
        
        let darkBlock = UIView()
        darkBlock.backgroundColor = UIColor.animationLightColor
        darkBlock.frame = CGRect(x: paddinLeft!, y: 0, width: width, height: height)
        darkBlock.layer.cornerRadius = 12
        sigleBlock.addSubview(darkBlock)
        
        let lightBlock = UIView()
        lightBlock.backgroundColor = UIColor.ultraLightGray
        lightBlock.frame = CGRect(x: paddinLeft!, y: 0, width: width, height: height)
        lightBlock.layer.cornerRadius = 12
        sigleBlock.addSubview(lightBlock)
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.ultraLightGray.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.5, 1]
        gradient.frame = lightBlock.frame
        gradient.frame.size.width = lightBlock.frame.width * 2
        
        //remove 16, because it is in different parents
        gradient.frame.origin.x = 0
        
        
        let angle = 45 * CGFloat.pi / 180
        gradient.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        lightBlock.layer.mask = gradient
        
        // Animation
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 1
        animation.fromValue = -view.frame.width
        animation.toValue = view.frame.width
        animation.repeatCount = Float.infinity

        gradient.add(animation, forKey: "nil")
        
        return sigleBlock
    }
    
    func loadingTripleBlock(view: UIView) -> UIView{
        let blockWidth = ((view.frame.width - 48) / 2)
        let holder = UIView()
        let topLeftBlock = loadingBlock(view: view, width: blockWidth, height: 67)
        let bottomLeftBlock = loadingBlock(view: view, width: blockWidth, height: 67)
        let rightBlock = loadingBlock(view: view, width: blockWidth, height: 150, paddinLeft: 0)
        
        let leftStackHolder =  UIStackView(arrangedSubviews: [topLeftBlock, bottomLeftBlock])
        leftStackHolder.axis = .vertical
        leftStackHolder.spacing = 16
        leftStackHolder.distribution = .fillEqually

        

        let mainStackHolder =  UIStackView(arrangedSubviews: [leftStackHolder, rightBlock])
        mainStackHolder.axis = .horizontal
        mainStackHolder.spacing = 16
        mainStackHolder.distribution = .fillEqually
        
        holder.addSubview(mainStackHolder)
        mainStackHolder.allSideConstraint(inView: holder)
        
        return holder
    }
    
}

extension UIButton{
    
    func standardButtonLayout(title: String, color: UIColor, cornerRadius: CGFloat? = 12) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = cornerRadius!
        button.backgroundColor = color
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }
    
    func signTextButton(firstText: String, secondText: String) -> UIButton{
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: firstText + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributedTitle.append(NSAttributedString(string: secondText, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
    
}
