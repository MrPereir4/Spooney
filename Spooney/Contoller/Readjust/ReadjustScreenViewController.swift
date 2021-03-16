//
//  ReadjustScreenViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 09/08/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import GoogleMobileAds
import UIKit

class ReadjustScreenViewController: UIViewController{
    
    //MARK: - Properties
    
    var titleString = String()
    
    var fromViewController: UIViewController?
    
    var allGoalsMainInfos: [(Int, Int, String)] = [(Int, Int, String)]()
    var userMonthIncome: Int = Int()
    
    var interstitial: GADInterstitial!

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        interstitial = createAndLoadInterstitial()
        configure()
    }
    
    //MARK: - Selector
    
    @objc private func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func updateAllGoals(){
        updateGoals()
//        presentAd()
    }

    //MARK: - Helper functions
    
    private func configureNavBar(){
        navigationItem.title = titleString
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    
    private func configure(){
        configureNavBar()
        configureUI()
    }
    
    private func configureUI(){
        
        let holder = UIView()
        view.addSubview(holder)
        holder.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, paddingRight: 16, paddingLeft: 16)
        
        
        view.backgroundColor = .darkerBackground
        let descLabel = UILabel()
        descLabel.font = UIFont.systemFont(ofSize: 22)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.text = "The adjust system will check each of your goals bill and refactor it based on each priority, and on the 30% salary reserved to your goals."
        
        let refactorButton = UIButton(type: .system)
        refactorButton.backgroundColor = .black
        refactorButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        refactorButton.setTitleColor(.white, for: .normal)
        refactorButton.setTitle("Readjust", for: .normal)
        refactorButton.addTarget(self, action: #selector(updateAllGoals), for: .touchUpInside)
        holder.addSubview(descLabel)
        holder.addSubview(refactorButton)
        descLabel.anchor(top: holder.topAnchor, right: holder.rightAnchor, left: holder.leftAnchor, paddingTop: 25)
        
        refactorButton.anchor(top: descLabel.bottomAnchor, paddingTop: 20, width: 160, height: 50)
        refactorButton.layer.cornerRadius = 12
        refactorButton.centerX(inView: view)
        
    }
    
    private func updateGoals(){
        addSendLoading()
        updateAllGoalsToNewValues(percentageAvaliable: 30, userMntIncome: userMonthIncome, allGoals: allGoalsMainInfos) {
            self.dismiss(animated: true) {
                self.fromViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Loading View

extension ReadjustScreenViewController{
    
    func addSendLoading(){
        let loadingView = LoadingFullSizeView()
        view.addSubview(loadingView)
        
        loadingView.frame = view.frame
    }
    
}

//MARK: - Ads

extension ReadjustScreenViewController: GADInterstitialDelegate{
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1544049467353622/7587182183")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }
    
    private func presentAd(){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            let alert = UIAlertController(title: "Ops, something went wrong", message: "We found a problem to readjust your installment, try again!", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                return
            }))
            self.present(alert, animated: true, completion: nil)
            print("Ad wast ready")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
    }
}
