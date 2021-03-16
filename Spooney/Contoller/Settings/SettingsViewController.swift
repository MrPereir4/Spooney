//
//  SettingsViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 14/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController{
    //MARK: - Properties
    var fullNameString: String!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - Selector
    @objc private func handleDismiss(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func signOut() {
        do {
            try Auth.auth().signOut()
            let root = LoginViewController()
            let nav = UINavigationController(rootViewController: root)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helper functions
    
    private func configure(){
        configureNavBar()
        configureUI()
    }
    
    private func configureNavBar(){
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func configureUI(){
        guard let fullNameString = fullNameString else {return}
        let fullName = UILabel()
        fullName.text = fullNameString
        fullName.textColor = .black
        fullName.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        
        view.addSubview(fullName)
        fullName.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, paddingTop: 25, paddingRight: 16, paddingLeft: 16)
        
        view.backgroundColor = .darkerBackground
        let signOutButton = UIButton(type: .system)
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.backgroundColor = .customSystemRed
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.layer.cornerRadius = 12
        signOutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        
        
        view.addSubview(signOutButton)
        signOutButton.anchor(right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, paddingRight: 16, paddingBottom: 32, paddingLeft: 16, height: 50)
    }
    
    
    
}
