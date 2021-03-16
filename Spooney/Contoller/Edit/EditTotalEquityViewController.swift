//
//  EditTotalEquityViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 01/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import Firebase

class EditTotalEquityViewController: UIViewController, UITextFieldDelegate{
    //MARK: - Properties
    
    var totalEquityTF: MainPickerView?
    
    var totalEquityAmt = 0
    var totalEquityNormalValue = ""
    
    private var contentStackHolder = UIStackView()
    private var scrollView = UIScrollView()
    
    private var addedNotification: NotificationView?
    
    var notificationTrigger = true

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    //MARK: - Selector
    
    @objc private func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSave(){
        if !(totalEquityTF!.tf.text?.isEmpty)!{
            
            self.addSendLoading()
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            REF_USERS.child(uid).updateChildValues(["totalEquity": totalEquityNormalValue]) { (error, ref) in
                if let error = error{
                    print(error)
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }else{
            if notificationTrigger == true{
                self.presentNotification(type: 0)
            }
            
        }
    }

    //MARK: - Helper functions
    private func configure(){
        configureNavBar()
        configureUI()
        delegate()
    }
    
    private func configureNavBar(){
        navigationItem.title = "Edit total equity"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
    }
    
    private func configureUI(){
        if #available(iOS 11.0, *) {
          scrollView.contentInsetAdjustmentBehavior = .never
        }
                
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    
        scrollView.frame.size = view.frame.size
        scrollView.fillSuperview()
        scrollView.backgroundColor = .white
    
        contentStackHolder.isLayoutMarginsRelativeArrangement = true
        contentStackHolder.axis = .vertical
    
        scrollView.addSubview(contentStackHolder)
    
        contentStackHolder.anchor(top: scrollView.topAnchor,
                                right: view.rightAnchor,
                                left: view.leftAnchor,
                                paddingRight: 16,
                                paddingLeft: 16)
     
        contentStackHolder.spacing = 20
    
        contentStackHolder.layoutMargins = UIEdgeInsets(top: 25, left: 0, bottom: 100, right: 0)
        
        
        totalEquityTF!.headerLabel.font = UIFont.systemFont(ofSize: 24)
        totalEquityTF!.headerLabel.textColor = .black
        
        totalEquityTF!.tf.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        contentStackHolder.addArrangedSubview(totalEquityTF!)
        
    }
    
    private func delegate(){
        totalEquityTF!.tf.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == totalEquityTF!.tf{
            
            totalEquityNormalValue = totalEquityNormalValue + string
            
            
            if let digit = Int(string){
                totalEquityAmt = totalEquityAmt * 10 + digit
                
                if totalEquityAmt > 1_000_000_000_00{
                    standardAlert(title: "Please, enter a value less than 1 billion")
                    totalEquityAmt = 0
                    totalEquityNormalValue = ""
                    totalEquityTF!.tf.text = ""
                }else{
                    totalEquityTF!.tf.text = MathConver.shared.updateFormatedValue(value: totalEquityAmt)
                }
                
            }

            if string == ""{
                totalEquityAmt = totalEquityAmt/10
                totalEquityTF!.tf.text = totalEquityAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: totalEquityAmt)
                
                totalEquityNormalValue = String(totalEquityNormalValue.dropLast())
            }
            
            print(totalEquityNormalValue)
        }
        return false
    }
}

//MARK: - Loading

extension EditTotalEquityViewController{
    func addSendLoading(){
        let loadingView = LoadingFullSizeView()
        view.addSubview(loadingView)
        
        loadingView.frame = view.frame
    }
}

//MARK: - Notification

extension EditTotalEquityViewController{
    
    func presentNotification(type: Int){
        notificationTrigger = false
        
        addedNotification = NotificationView(type: type, view: view, color: .customSystemRed)
        view.addSubview(addedNotification!)
        addedNotification!.configureUI()
        
        let topSafeArea = self.view.safeAreaInsets.top
        
        addedNotification?.textContent.text = "Fill all the fields"
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.addedNotification?.holder.frame.origin.y = topSafeArea + 20
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.addedNotification?.holder.frame.origin.y = -40
            }) { (_) in
                self.notificationTrigger = true
                self.addedNotification?.removeFromSuperview()
            }
        }
    }
}



