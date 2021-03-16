//
//  StandardPopupViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 10/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

protocol StandardPopupViewControllerDelegate {
    func handleIcon()
}

class StandardPopupViewController: UIViewController{
    //MARK: - Properties
    
    var delegate: StandardPopupViewControllerDelegate?
    
    var block: InfoBlockDisplayView?
    var blockHeight: CGFloat?
    var theHeight:CGFloat = 0
    
    var viewTitle = String()
    var viewContent = String()
    var subContent = [(String, String)]()
    var isCenteredInView: Bool? = false
    var status: Int = 0
    var shouldHaveStatus: Bool? = false
    var shouldHavePerc: Bool? = false
    var percentValue: Int? = Int()
    var percentTitle = String()
    var shouldHaveIcon: Bool? = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        theHeight = view.frame.size.height
        view.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if isCenteredInView == true{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.block?.frame.origin.y = (self.theHeight / 2) - (self.blockHeight! - 50)
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.block?.frame.origin.y = self.theHeight - (self.blockHeight! + 50)
            }, completion: nil)
        }
    }
    
    //MARK: - Selectors
    @objc private func handleIconTap(){
        delegate?.handleIcon()
    }
    
    //MARK: - Helper functions
    
    func configureUI(){
        block = InfoBlockDisplayView(title: viewTitle, content: viewContent, subContent: subContent, shouldHavePerc: shouldHavePerc, percentTitle: percentTitle, shouldHaveStatus: shouldHaveStatus, status: status, shouldHaveIcon: shouldHaveIcon, percentValue: percentValue)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleIconTap))
        block?.icon.addGestureRecognizer(tap)
        
        block?.layer.cornerRadius = 12
        view.addSubview(block!)
        block?.mainStackHolder.layoutIfNeeded()
        block?.holder.layoutIfNeeded()
        
        blockHeight = (block?.mainStackHolder.frame.size.height)! + 32
        
        let theHeight = view.frame.size.height
        
        block?.frame = CGRect(x: 16, y: theHeight, width: self.view.frame.width - 32, height: blockHeight!)
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.view == self.view{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.block?.frame = CGRect(x: 16, y: self.theHeight, width: self.view.frame.width - 32, height: self.blockHeight!)
            }) { (_) in
                self.dismiss(animated: false, completion: {
                    self.block?.removeFromSuperview()
                })
            }
        }
    }
    
}
