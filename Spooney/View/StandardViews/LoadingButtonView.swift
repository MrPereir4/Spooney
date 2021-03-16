//
//  LoadingButtonView.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 14/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class LoadingButton: UIButton {
    var activityIndicator: UIActivityIndicatorView!

    let activityIndicatorColor: UIColor = .gray

    func loadIndicator(_ shouldShow: Bool) {
        if shouldShow {
            if (activityIndicator == nil) {
                activityIndicator = createActivityIndicator()
            }
            self.isEnabled = false
            self.alpha = 0.7
            showSpinning()
        } else {
            activityIndicator.stopAnimating()
            self.isEnabled = true
            self.alpha = 1.0
        }
    }

    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = activityIndicatorColor
        return activityIndicator
    }

    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        positionActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func positionActivityIndicatorInButton() {
        let trailingConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .trailing,
                                                   multiplier: 1, constant: 16)
        self.addConstraint(trailingConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: activityIndicator,
                                                   attribute: .centerY,
                                                   multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
    func standardButton(title: String){
        self.backgroundColor = .black
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.layer.cornerRadius = 12
    }
}
