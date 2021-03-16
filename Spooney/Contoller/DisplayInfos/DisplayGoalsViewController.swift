//
//  DisplayGoalsViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 10/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import GoogleMobileAds
import UIKit
import Firebase

class DisplayGoalsViewController: UIViewController{
    //MARK: - Properties
    
    private var contentList: ViewsListWithHeaderView?
    
    var contentLabel = UILabel()
    
    private let contentStackHolder = UIStackView()
    private let scrollView = UIScrollView()
    
    private var goalArray: [(String, String, String, String, String, String)] = []
    private var allGoalsMainInfos: [(Int, Int, String)] = [(Int, Int, String)]()
    
    private var totalBill = 0
    
    var userMonthIncome: Int = Int()
    var shouldShowReadjust: Bool = Bool()
    
    private var addedNotification: NotificationView?
    private var notificationTrigger: Bool = true
    
    var adTrigger: Bool = Bool()
    var interstitial: GADInterstitial!
    
    var fromViewController: HomeViewController!
    
    let loadingView = UIView()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(shouldShowReadjust)
        view.backgroundColor = .darkerBackground
        configureNavBar()
        firebaseUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        shouldDisplayAd()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        fromViewController.interstitial = fromViewController.createAndLoadInterstitial()
    }
    
    //MARK: - Selector
    
    @objc private func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func displayReadjustInstallment(){
        let root = ReadjustScreenViewController()
        root.allGoalsMainInfos = allGoalsMainInfos
        root.userMonthIncome = userMonthIncome
        root.fromViewController = self
        root.titleString = "Readjust installment"
        let nav = UINavigationController(rootViewController: root)
        self.present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helper functions
        
    private func configure(){
        //Remove loading view
        loadingView.removeFromSuperview()
        configureUI()
        configureContentDisplayBlockHeight()
        configureScrollHeight()
        configureTableView()
        
    }
        
    private func configureNavBar(){
        navigationItem.title = "Goals"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    private func shouldDisplayAd(){
        print("okdd")
        if adTrigger == true{
            print("okokoko")
            if interstitial.isReady{
                interstitial.present(fromRootViewController: self)
            }else{
                print("Ad wasnt ready")
            }
        }
    }
    
    private func configureLoadingView(){
        view.backgroundColor = .darkerBackground
        view.addSubview(loadingView)
        loadingView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        
        let stack = UIStackView()
        loadingView.addSubview(stack)
        stack.anchor(top: loadingView.topAnchor, right: loadingView.rightAnchor, left: loadingView.leftAnchor)
        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        let titleBlock = UIView().loadingBlock(view: view, width:view.frame.width / 2, height: 31)
        titleBlock.heightAnchor.constraint(equalToConstant: 31).isActive = true
        stack.addArrangedSubview(titleBlock)
        
        stack.setCustomSpacing(4, after: titleBlock)
        
        let contentBlock = UIView().loadingBlock(view: view, width: (view.frame.width / 4) * 3, height: 42)
        contentBlock.heightAnchor.constraint(equalToConstant: 42).isActive = true
        stack.addArrangedSubview(contentBlock)
        
        stack.setCustomSpacing(50, after: contentBlock)
        
        let contentStack = UIStackView()
        stack.addArrangedSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 5
        
        let contentHeaderBlock = UIView().loadingBlock(view: view, width:view.frame.width / 5, height: 20)
        contentHeaderBlock.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(contentHeaderBlock)
        
        contentStack.setCustomSpacing(10, after: contentHeaderBlock)
        
        for _ in 1...3{
            let contentHeaderBlock = UIView().loadingBlock(view: view, width:view.frame.width - 32, height: 81)
            contentHeaderBlock.heightAnchor.constraint(equalToConstant: 81).isActive = true
            contentStack.addArrangedSubview(contentHeaderBlock)
        }

    }
        
    private func configureUI(){
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
                
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        scrollView.frame.size = view.frame.size
        scrollView.fillSuperview()
        scrollView.backgroundColor = .darkerBackground

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
          
        let headerLabel = UILabel()
        headerLabel.text = "Goals bill"
        headerLabel.font = UIFont.systemFont(ofSize: 28)
            
        
        let convertedValue = MathConver.shared.updateFormatedValue(value: totalBill)
        contentLabel.text = convertedValue
        contentLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)

        
                
        let stack = UIStackView(arrangedSubviews: [headerLabel, contentLabel])
        stack.axis = .vertical
        
        let adjButton = UIButton(type: .system)
        adjButton.backgroundColor = .customSystemBlue
        adjButton.layer.cornerRadius = 12
        adjButton.setTitle("Readjust installments", for: .normal)
        adjButton.setTitleColor(.white, for: .normal)
        adjButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        adjButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        adjButton.addTarget(self, action: #selector(displayReadjustInstallment), for: .touchUpInside)
        
        contentStackHolder.addArrangedSubview(stack)
        
        
        if shouldShowReadjust == true{
            contentStackHolder.addArrangedSubview(adjButton)
        }else{
            contentStackHolder.setCustomSpacing(50, after: stack)
        }
        
                
        
                
        contentList = ViewsListWithHeaderView(title: "Goals bill")
                
        contentStackHolder.addArrangedSubview(contentList!)
    }
        
    private func firebaseUserData(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
           
        retrieveUserGoals(uid: uid) {
            self.configure()
        }
    }
        
    private func retrieveUserGoals(uid: String, completion: @escaping() -> Void){
        UserService.shared.fetchUserGoals(uid: uid) { (goals) in

            for child in goals.children.allObjects as! [DataSnapshot]{
                let goalUid = child.key
                let dict = child.value as? [String: Any] ?? [:]
                let name = dict["name"] as! String
                let price = dict["price"] as! String
                let priority = dict["priority"] as! Int
                let installment = dict["installment"] as! String
                let expDate = dict["expDate"] as! String
                let convertedExpDate = DateConver.shared.convertDate(date: expDate)
                let remainingInst = String(Int(price)! / Int(installment)!)
                self.goalArray.append((name, price, convertedExpDate, installment, remainingInst, goalUid))
                
                self.allGoalsMainInfos.append((priority, Int(installment)!, goalUid))
                
                self.totalBill += Int(dict["price"] as! String)!

            }
            completion()
        }
    }
        
    private func configureScrollHeight(){
        contentStackHolder.layoutIfNeeded()
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        let safeAreas = (window?.safeAreaInsets.bottom)! + 8
        
        if contentStackHolder.frame.height > view.frame.height - safeAreas{
            scrollView.contentSize.height = contentStackHolder.frame.height + safeAreas
        }
    }
        
    private func configureContentDisplayBlockHeight(){
        contentList!.layoutIfNeeded()
        let fullIncomeBillHeight = contentList!.titleLabel.frame.size.height + (CGFloat(goalArray.count) * 86) + 5//5 is the padding
        contentList?.heightAnchor.constraint(equalToConstant: fullIncomeBillHeight).isActive = true
    }
}

//MARK: - Animation

extension DisplayGoalsViewController{
    
    func presentNotification(type: Int){
        notificationTrigger = false
        
        addedNotification = NotificationView(type: type, view: view, color: .customSystemRed)
        view.addSubview(addedNotification!)
        addedNotification!.configureUI()
        
        let topSafeArea = self.view.safeAreaInsets.top
        
        addedNotification?.textContent.text = "Goal deleted"
        
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

//MARK: - Table View

extension DisplayGoalsViewController: UITableViewDelegate, UITableViewDataSource{
    
    private func configureTableView(){
        contentList?.mainTableView.register(ContentDisplayBlock.self, forCellReuseIdentifier: "blockCell")
        contentList?.mainTableView.delegate = self
        contentList?.mainTableView.dataSource = self
        contentList?.mainTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if goalArray.count == 0{
            
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: (contentList?.frame.origin.y)! + (contentList?.mainTableView.frame.origin.y)!, width: view.frame.size.width, height: 50))
            emptyLabel.text = "There are no bills added"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .lightGray
            view.addSubview(emptyLabel)
            
            return 0
        }else{
            return goalArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let section = IndexSet(integer: indexPath.section)
        
        if editingStyle == .delete{
            
            let alert = UIAlertController(title: "Delete \(goalArray[indexPath.section].0)", message: "Are you sure you want to delete \(goalArray[indexPath.section].0)?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.totalBill = self.totalBill - Int(self.goalArray[indexPath.section].1)!
                self.userMonthIncome -= Int(self.goalArray[indexPath.section].1)!
                self.allGoalsMainInfos.removeAll(where: {$2 == self.goalArray[indexPath.section].5})
                self.contentLabel.text = MathConver.shared.updateFormatedValue(value: self.totalBill)
                
                
                deleteGoal(goalUid: self.goalArray[indexPath.section].5, view: self)
                self.goalArray.remove(at: indexPath.section)
                self.contentList?.mainTableView.deleteSections(section, with: .fade)
                return
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                return
            }))
            
            self.present(alert, animated: true, completion: nil)
        }else{
                
        }
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        view.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! ContentDisplayBlock
        //cell.selectionStyle = .none
        let intPrice = Int(goalArray[indexPath.section].1)
        let convertedPrice = MathConver.shared.updateFormatedValue(value: intPrice!)
        
        cell.title = goalArray[indexPath.section].0
        cell.content = convertedPrice!
        let installmentsRemaining = goalArray[indexPath.section].4
        cell.subContent = "\(installmentsRemaining) installments remaining"
        
        cell.layer.cornerRadius = 12
        cell.configureUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = StandardPopupViewController()
        view.viewTitle = goalArray[indexPath.section].0
        let intPrice = Int(goalArray[indexPath.section].1)
        let expDate = goalArray[indexPath.section].2
        let installment = Int(goalArray[indexPath.section].3)
        let convertedPrice = MathConver.shared.updateFormatedValue(value: intPrice!)
        let convertedInstallment = MathConver.shared.updateFormatedValue(value: installment!)
        view.viewContent = convertedPrice!
        view.subContent = [("Monthly installment", convertedInstallment!), ("Forecast to finish", expDate)]
        
        view.shouldHavePerc = true
        let percentBillValue = round(Float(installment!)/Float(userMonthIncome) * 100)
        view.percentValue = Int(percentBillValue)
        view.modalPresentationStyle = .overFullScreen
        self.present(view, animated: false, completion: nil)
    }
}
