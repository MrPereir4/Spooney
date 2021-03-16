//
//  CircleBarView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 01/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class CircleBarView: UIView{
    
    let shapeLayer = CAShapeLayer()
    let percentageNumber = UILabel()
    
    var percent: Int = 0
    
    required init(percent: Int) {
        self.percent = percent
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(){
        shapeLayer.removeFromSuperlayer()
        percentageNumber.removeFromSuperview()
        
        
        
        percentageNumber.text = "\(percent)%"
        percentageNumber.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        percentageNumber.textColor = .black

        let center = self.center
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 25, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        
        
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        shapeLayer.strokeEnd = 0
        
        
        
        layer.addSublayer(shapeLayer)
        self.addSubview(percentageNumber)
        percentageNumber.centerX(inView: self)
        percentageNumber.centerY(inView: self)
        
        shapeLayer.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
    }
    
    private func calculatingPerncetageToAnimate(value: Int) -> CGFloat{
        let convertedValueToAnimate: CGFloat = (0.8 * CGFloat(value)) / 100
        return convertedValueToAnimate
    }
    
    func animateView(){
        var convertedValue = calculatingPerncetageToAnimate(value: percent)
        
        if percent >= 100{
            convertedValue = 0.8
        }
        
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = convertedValue
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        
        shapeLayer.add(basicAnimation, forKey: "bAnim")
    }
    
}
