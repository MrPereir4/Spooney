//
//  LoginViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 03/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class LoginViewController: LBTAFormController{
    //MARK: - Properties
    
    private let emailTF = MainPickerView(title: "Email", keyboardType: .emailAddress)
    private let passwordTF = MainPickerView(title: "Password", keyboardType: .default)
    
    private let dontHaveAccButton = UIButton().signTextButton(firstText: "Don’t have an account?", secondText: "Sign up")
    
    private var errorMessage = StandardErrorTextView()
    private var addedNotification: NotificationView?
    
    private var signinButton = LoadingButton()
    
    

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - Selector
    
    @objc private func handlePresentSignup(){
        presentDetailFromTop(UINavigationController(rootViewController: CreateAccountViewController()))
    }
    
    @objc private func handleSignin(){
        signinUser()
    }
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }

    //MARK: - Helper functions
    
    private func configure(){
        configureNavBar()
        configureUI()
        configureDismissKeyboard()
    }
    
    private func configureNavBar(){
        navigationItem.title = "Log in"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        
        if #available(iOS 12.0, *){
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        }
    }
    
    private func configureUI(){
        let stack = formContainerStackView
        stack.axis = .vertical
        stack.spacing = 25
        stack.layoutMargins = .init(top: 25, left: 16, bottom: 34, right: 16)
        
        stack.addArrangedSubview(emailTF)
        stack.addArrangedSubview(passwordTF)
        stack.addArrangedSubview(dontHaveAccButton)
        stack.addArrangedSubview(errorMessage)
        stack.addArrangedSubview(signinButton)
        
        errorMessage.isHidden = true
        
        emailTF.tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        passwordTF.tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        passwordTF.tf.isSecureTextEntry = false
        
        //Adding button to the bottom
        signinButton.standardButton(title: "Sign in")
        signinButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dontHaveAccButton.addTarget(self, action: #selector(handlePresentSignup), for: .touchUpInside)
        
        signinButton.addTarget(self, action: #selector(handleSignin), for: .touchUpInside)
    }
    
    private func signinUser(){
        errorMessage.isHidden = true
        
        guard let email = emailTF.tf.text else {return}
        guard let password = passwordTF.tf.text else {return}
        
        if email.isEmpty{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "Email is empty"
            return
        }else if password.isEmpty{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "password is empty"
            return
        }
        
        signinButton.setTitle("Signing in", for: .normal)
        signinButton.loadIndicator(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("Error \(error)")
                self.presentNotification()
                self.signinButton.setTitle("Sign in", for: .normal)
                self.signinButton.loadIndicator(false)
                self.errorMessage.isHidden = false
                self.errorMessage.textLabel.text = "Email or password is incorrect"
                return
            }
            
            
            let controller = UINavigationController(rootViewController: HomeViewController())
            self.presentDetailFromRight(controller)
            
        }
        
    }
    
    private func presentNotification(){
        addedNotification = NotificationView(type: 2, view: view, color: .customSystemRed)
        addedNotification?.textContent.text = "Failed to login"
        view.addSubview(addedNotification!)
        addedNotification!.configureUI()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.addedNotification?.holder.frame.origin.y = 40
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.addedNotification?.holder.frame.origin.y = -40
            }) { (_) in
                self.addedNotification?.removeFromSuperview()
            }
        }
    }
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}
