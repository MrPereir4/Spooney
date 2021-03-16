//
//  CreateAccountViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 03/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class CreateAccountViewController: LBTAFormController{
    
    //MARK: - Properties
    
    private let emailTF = MainPickerView(title: "Email")
    private let passwordTF = MainPickerView(title: "Password")
    private let confirmPasswordTF = MainPickerView(title: "Confirm password")
    
    private let alreadyHaveAccButton = UIButton().signTextButton(firstText: "Already have an account?", secondText: "Sign in")
    
    private var errorMessage = StandardErrorTextView()
    
    private let signupButton = LoadingButton()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        
    }

    //MARK: - Selector
    
    @objc private func handlePresentSignin(){
        presentDetailFromBottom(UINavigationController(rootViewController: LoginViewController()))
    }
    
    @objc private func handleCreateUser(){
        createUser()
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
        navigationItem.title = "Create account"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 12.0, *){
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        }
    }
    
    private func configureUI(){
        errorMessage.isHidden = true
        
        let stack = formContainerStackView
        stack.axis = .vertical
        stack.spacing = 25
        stack.layoutMargins = .init(top: 25, left: 16, bottom: 34, right: 16)
        
        stack.addArrangedSubview(emailTF)
        stack.addArrangedSubview(passwordTF)
        stack.addArrangedSubview(confirmPasswordTF)
        stack.addArrangedSubview(alreadyHaveAccButton)
        stack.addArrangedSubview(errorMessage)
        stack.addArrangedSubview(signupButton)
        
        emailTF.tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        passwordTF.tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        confirmPasswordTF.tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        passwordTF.tf.isSecureTextEntry = false
        confirmPasswordTF.tf.isSecureTextEntry = false
        
        signupButton.standardButton(title: "Create account")
        signupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        alreadyHaveAccButton.addTarget(self, action: #selector(handlePresentSignin), for: .touchUpInside)
        
        signupButton.addTarget(self, action: #selector(handleCreateUser), for: .touchUpInside)
        
    }
    
    private func createUser(){
        errorMessage.isHidden = true
        guard let email = emailTF.tf.text else {return}
        guard let password = passwordTF.tf.text else {return}
        guard let confPassword = confirmPasswordTF.tf.text else {return}
        
        if email.isEmpty{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "Email is empty"
            return
        }else if password.isEmpty{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "password is empty"
            return
        }else if confPassword.isEmpty{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "Confirm your password is empty"
            return
        }else if password != confPassword{
            errorMessage.isHidden = false
            errorMessage.textLabel.text = "Passwords are not equal"
            return
        }
        
        signupButton.setTitle("Creating", for: .normal)
        signupButton.loadIndicator(true)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("Error return \(error)")
                print(error.localizedDescription)
                if error.localizedDescription == "The email address is badly formatted."{
                    self.errorMessage.isHidden = false
                    self.errorMessage.textLabel.text = "Please, enter a valid email address"
                }else{
                    self.errorMessage.isHidden = false
                    self.errorMessage.textLabel.text = error.localizedDescription
                }
                
                self.signupButton.setTitle("Create account", for: .normal)
                self.signupButton.loadIndicator(false)
                return
            }
            
            let controller = UINavigationController(rootViewController: MainInfosPickerController())
            self.presentDetailFromRight(controller)
            
        }
        
    }
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}
