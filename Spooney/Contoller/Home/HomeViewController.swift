//
//  HomeViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import GoogleMobileAds
//import LBTATools
import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController{
    
    //MARK: - Properties
    
    private let totalEquityBlock = TotalEquityBlockView(totalValue: "", lastUpdate: "today")
    
    private let mainInfosTripleBlock = TripleContentBlockView(topLeftBlock: "Monthly income",
                                                              bottomLeftBlock: "Fixed month bill",
                                                              rightBlock: "Total bill",
                                                              shouldHavePercent: true)
    private let goalsBillBlock = SingleSmallBlockView(title: "Goals bill", shouldHavePercent: true)
    private let addAndGoalsInfoTripleBlock = TripleContentBlockView(topLeftIsButton: true,
                                                                    topLeftBlock: "Add bill",
                                                                    bottomLeftIsButton: true,
                                                                    bottomLeftBlock: "Add goal",
                                                                    rightBlock: "Active goals",
                                                                    buttonColor: [.customSystemGreen, .customSystemBlue, .white],
                                                                    rightIsBiggerText: true)
    private let instantBillButton = SingleSmallBlockView(isButton: true, title: "Instant bill", backColor: .pinkRed)
    private let getPremiumButton = SingleSmallBlockView(isButton: true, title: "Get premium", backColor: .black)
    
    private var totalEquityArray: [String] = []
    
    private var allGoalsPriority: [Int] = [Int]()
    
    private var userNameString: String = String()
    
    private var totalEquityVal = ""
    private var monthIncomeVal = ""
    private var monthIncomeDate = 0
    
    private var activeMonthGoals = 0
    private var totalGoalsBill: Int = 0
    private var totalGoalInstallmentBill: Int = 0
    private var totalFixedBill: Int = 0
    private var totalBill: Int = 0
    
    var timer: Timer!
    
    var totalEquityPopup: StandardPopupViewController?
    
    //Triggers
    private var triggerUserData: Bool = false
    private var triggerUserBills: Bool = false
    private var triggerUserGoals: Bool = false
    private var triggerUserInsBill: Bool = false
    private var shouldDisplayReadjustInst: Bool = false
    
    var adTrigger: Bool = false
    var interstitial: GADInterstitial!
    
    private var triggerObserver: Bool = false
    
    private func definedValues(totalEquity: String, monthIncome: String, monthIncomeDate: Int){
        totalEquityVal = totalEquity
        monthIncomeVal = monthIncome
        self.monthIncomeDate = monthIncomeDate
    }
    

    private let contentStackHolder = UIStackView()
    private let scrollView = UIScrollView()
    
    var addedNotification: NotificationView?
    
    let loadingView = UIView()
    
    var statusColorInt: Int = 0
    
    //MARK: - Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoadingView()
        firebaseUserData()
        configureNavBar()
        interstitial = createAndLoadInterstitial()
        //signOut()
    }
    
    //MARK: - Selector
    @objc private func handleAddBill(){
        presentAddBills(view: self)
    }
    
    @objc private func handleAddGoal(){
        presentAddGoal(view: self, goalsPriorityArray: self.allGoalsPriority, userMonthInc: Int(self.monthIncomeVal)!)
    }
    
    @objc private func handleTotalEquity(){
        totalEquityPopup = StandardPopupViewController()
        totalEquityPopup!.delegate = self
        totalEquityPopup!.viewTitle = "Total equity"
        totalEquityPopup!.viewContent = MathConver.shared.updateFormatedValue(value: Int(totalEquityArray[0])!)!
        totalEquityPopup!.isCenteredInView = true
        totalEquityPopup!.shouldHaveStatus = true
        totalEquityPopup?.status = self.statusColorInt
        totalEquityPopup!.shouldHaveIcon = true
        
        let forecastVal: Int = calculateForecastForNextMonth(totalEquity: Int(self.totalEquityVal)!,
                                                        monthIncoming: Int(self.monthIncomeVal)!,
                                                        totalBill: self.totalBill,
                                                        totalGoal: self.totalGoalInstallmentBill)
        let convertedForecastVal = MathConver.shared.updateFormatedValue(value: forecastVal)
        
        totalEquityPopup?.subContent = [("Forecast for next month", convertedForecastVal!)]
        totalEquityPopup!.modalPresentationStyle = .overFullScreen
        self.present(totalEquityPopup!, animated: false, completion: nil)
        showAd()
    }
    
    @objc private func handleInstantBill(){
        let root = AddInstantBillViewController()
        root.fromViewController = self
        root.adTrigger = adTrigger
        let nav = UINavigationController(rootViewController: root)
        present(nav, animated: true, completion: nil)
        showAd()
    }
    
    @objc private func handleTotalBill(){
        let root = DisplayBillsViewController()
        root.userMonthIncome = Int(monthIncomeVal)!
        root.adTrigger = adTrigger
        root.fromViewController = self
        root.interstitial = interstitial
        let nav = UINavigationController(rootViewController: root)
        nav.modalPresentationStyle = .formSheet
        self.present(nav, animated: true, completion: nil)
        showAd()
    }
    
    @objc private func handleGoalsBill(){
        let root = DisplayGoalsViewController()
        root.userMonthIncome = Int(monthIncomeVal)!
        root.shouldShowReadjust = shouldDisplayReadjustInst
        root.adTrigger = adTrigger
        root.fromViewController = self
        root.interstitial = interstitial
        let nav = UINavigationController(rootViewController: root)
        nav.modalPresentationStyle = .formSheet
        self.present(nav, animated: true, completion: nil)
        showAd()
    }
    
    @objc private func handlePresentSettings(){
        let root = SettingsViewController()
        root.fullNameString = self.userNameString
        let nav = UINavigationController(rootViewController: root)
        self.present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    private func configureNavBar(){
        navigationItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        let play = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(handlePresentSettings))
        navigationItem.rightBarButtonItems = [play]
    }
    
    private func firebaseUserData(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        retrieveUserData(uid: uid) { () in
            self.triggerUserData = true
            self.buildUI()
        }
        
        retrieveUserGoalsWithObserver(uid: uid) {
            self.triggerUserGoals = true
            self.buildUI()
        }
        
        retrieveUserBillsWithObserver(uid: uid) {
            self.triggerUserBills = true
            self.buildUI()
        }
        
        retrieveInstantBillWithObserver{
            self.triggerUserInsBill = true
            self.buildUI()
        }
        
        retrieveChangedGoalWithObserver(uid: uid) {}
        
    }
    
    private func retrieveUserData(uid: String, completion: @escaping() -> Void){
        UserService.shared.fetchUserData(uid: uid) { (user) in
            self.definedValues(totalEquity: user.totalEquity, monthIncome: user.monthIncome, monthIncomeDate: Int(user.incomeDate)!)
            self.totalEquityArray.append(user.totalEquity)
            self.userNameString = user.firstName + " " + user.lastName
            
            comparingValues(incomeSalaryDate: self.monthIncomeDate, userIncome: Int(self.totalEquityVal)!, userSalary: Int(user.monthIncome)!) { (intVal) in
                self.statusColorInt = intVal
                completion()
            }
        }
    }
    
    private func buildUI(){
        if triggerUserData == true && triggerUserGoals == true && triggerUserBills == true && triggerUserInsBill == true{
            self.configure()
        }
    }
    
    private func configure(){
        //Remove loading view
        loadingView.removeFromSuperview()
        configureUI()
        configureValues()
        configureScrollHeight()
        configureGesturePress()
        
        //Observers
        userDataObserver()
        removeGoalWithObserver()
        removeBillWithObserver()
        removeInstantBillObserver()
        
        triggerObserver = true
        
        startTimer()
        
        //Notification
        notificationAuthorization()
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
        
        
        let firstSingleBlock = UIView().loadingBlock(view: view, width:view.frame.width - 32, height: 150)
        firstSingleBlock.heightAnchor.constraint(equalToConstant: 150).isActive = true
        stack.addArrangedSubview(firstSingleBlock)
        
        let firstTripleBlock = UIView().loadingTripleBlock(view: view)
        firstTripleBlock.heightAnchor.constraint(equalToConstant: 150).isActive = true
        stack.addArrangedSubview(firstTripleBlock)
        
        let secondSingleBlock = UIView().loadingBlock(view: view, width:view.frame.width - 32, height: 80)
        secondSingleBlock.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.addArrangedSubview(secondSingleBlock)
        
        let secondTripleBlock = UIView().loadingTripleBlock(view: view)
        secondTripleBlock.heightAnchor.constraint(equalToConstant: 150).isActive = true
        stack.addArrangedSubview(secondTripleBlock)
        
        let thirdSingleBlock = UIView().loadingBlock(view: view, width:view.frame.width - 32, height: 80)
        thirdSingleBlock.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stack.addArrangedSubview(thirdSingleBlock)
    }
    
    private func startTimer(){
        print("ok")
        timer = Timer.scheduledTimer(withTimeInterval: 1600.0, repeats: true) { (timer) in
            print("boa")
            self.adTrigger = true
        }
        //RunLoop.current.add(timer, forMode: .common)
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
       
        contentStackHolder.layoutMargins = UIEdgeInsets(top: 25, left: 0, bottom: 50, right: 0)
        
        
        contentStackHolder.addArrangedSubview(totalEquityBlock)
        contentStackHolder.addArrangedSubview(mainInfosTripleBlock!)
        contentStackHolder.addArrangedSubview(goalsBillBlock!)
        contentStackHolder.addArrangedSubview(addAndGoalsInfoTripleBlock!)
        contentStackHolder.addArrangedSubview(instantBillButton!)
        contentStackHolder.addArrangedSubview(getPremiumButton!)
        
        totalEquityBlock.heightAnchor.constraint(equalToConstant: 150).isActive = true
        mainInfosTripleBlock!.heightAnchor.constraint(equalToConstant: 150).isActive = true
        goalsBillBlock!.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addAndGoalsInfoTripleBlock!.heightAnchor.constraint(equalToConstant: 150).isActive = true
        instantBillButton!.heightAnchor.constraint(equalToConstant: 70).isActive = true
        getPremiumButton!.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func configureScrollHeight(){
        contentStackHolder.layoutIfNeeded()
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        let safeAreas = (window?.safeAreaInsets.bottom)! + 8
        
        if contentStackHolder.frame.height > view.frame.height - safeAreas{
            scrollView.contentSize.height = contentStackHolder.frame.height + safeAreas
        }
    }
    
    func presentNotification(type: Int){
        addedNotification = NotificationView(type: type, view: view)
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(addedNotification!)
        addedNotification!.configureUI()
        
        UIView.animate(withDuration: 0.3, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.addedNotification?.holder.frame.origin.y = 40
        }) { (_) in
            UIView.animate(withDuration: 0.3, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.addedNotification?.holder.frame.origin.y = -40
            }) { (_) in
                self.addedNotification?.removeFromSuperview()
            }
        }
    }
    
    
    private func configureGesturePress(){
        let billTap = UITapGestureRecognizer(target: self, action: #selector(handleAddBill))
        addAndGoalsInfoTripleBlock?.topLeftContainer.addGestureRecognizer(billTap)
        
        let goalTap = UITapGestureRecognizer(target: self, action: #selector(handleAddGoal))
        addAndGoalsInfoTripleBlock?.bottomLeftContainer.addGestureRecognizer(goalTap)
        
        
        let totalEquityTap = UITapGestureRecognizer(target: self, action: #selector(handleTotalEquity))
        totalEquityBlock.addGestureRecognizer(totalEquityTap)
        
        let totalBillTap = UITapGestureRecognizer(target: self, action: #selector(handleTotalBill))
        mainInfosTripleBlock?.rightContentHolder.addGestureRecognizer(totalBillTap)
        
        let goalsBillTap = UITapGestureRecognizer(target: self, action: #selector(handleGoalsBill))
        goalsBillBlock?.contentBlock.addGestureRecognizer(goalsBillTap)
        
        instantBillButton?.contentButton.addTarget(self, action: #selector(handleInstantBill), for: .touchUpInside)
    }
}

extension HomeViewController: StandardPopupViewControllerDelegate{
    
    func handleIcon() {
        totalEquityPopup!.dismiss(animated: false, completion: nil)
        let root = EditTotalEquityViewController()
        let view = UINavigationController(rootViewController: root)
        guard let totalEquity = Int(totalEquityArray[0]) else {return}
        let convertedTotalEquity = MathConver.shared.updateFormatedValue(value: totalEquity)
        root.totalEquityTF = MainPickerView(title: convertedTotalEquity, keyboardType: .numberPad, shouldHaveHeader: true, headerString: "Total equity")
        view.modalPresentationStyle = .pageSheet
        self.present(view, animated: true, completion: nil)
    }
    
    
    
    
}

//MARK: - Configure observers

extension HomeViewController{
    
    func userDataObserver(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.userDataObserver(uid: uid) { (snapshot) in
            let newValue = snapshot.value as! String
            self.totalEquityArray[0] = newValue
            self.totalEquityBlock.totalValueLabel.text = MathConver.shared.updateFormatedValue(value: Int(newValue)!)
        }
    }
    
    private func retrieveUserGoalsWithObserver(uid: String, completion: @escaping() -> Void){
        GoalService.shared.fetchGoalObserver(uid: uid) { (goals) in
            self.allGoalsPriority.append(goals.priority)
            self.activeMonthGoals = self.activeMonthGoals + 1
            self.totalGoalsBill += Int(goals.price)!
            self.totalGoalInstallmentBill += Int(goals.monInstallment)!
            self.assigningGoalBillValueBlock()
            self.assigningActiveGoalsValueBlock()
            
            if self.triggerObserver == true{
                self.assigningNewStatusColor()
            }
            self.configureGesturePress()
            
        }
        
        completion()
    }
    
    private func retrieveChangedGoalWithObserver(uid: String, completion: @escaping() -> Void){
        GoalService.shared.goalEditObserver(uid: uid) { (goal) in
            self.goalsBillBlock?.percentValueInt = 30
            self.shouldDisplayReadjustInst = false
            self.goalsBillBlock?.configureUI()
            self.configureGesturePress()
            if self.triggerObserver == true{
                self.assigningNewStatusColor()
            }
            completion()
        }
    }
    
    private func removeGoalWithObserver(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        GoalService.shared.removeGoalObserver(uid: uid) { (goal) in
            self.totalGoalsBill = self.totalGoalsBill - Int(goal.price)!
            self.totalGoalInstallmentBill -= Int(goal.monInstallment)!
            self.activeMonthGoals = self.activeMonthGoals - 1
            self.assigningGoalBillValueBlock()
            self.assigningActiveGoalsValueBlock()
            
           if self.triggerObserver == true{
               self.assigningNewStatusColor()
           }
            self.configureGesturePress()
        }
    }
    
    
    private func retrieveUserBillsWithObserver(uid: String, completion: @escaping() -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        BillService.shared.fetchBillObserver(uid: uid) { (bills) in
            var convertedDate = String()
            if bills.repetition == 0{
                let date = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                
                let month = components.month
                let day = components.day
                
                if Int(bills.billingDate)! > day!{
                    convertedDate = "\(month!)/\(bills.billingDate)"
                }else{
                    let nextMonth: Int
                    if month == 12{
                        nextMonth = 1
                    }else{
                        nextMonth = month! + 1
                    }
                    
                    convertedDate = "\(nextMonth)/\(bills.billingDate)"
                    
                }
                self.totalFixedBill += Int(bills.price)!
                
            }else{
                convertedDate = DateConver.shared.convertDate(date: bills.billingDate)
            }
            self.totalBill += Int(bills.price)!
            self.assigningTotalBillValueBlock()
            
            if self.triggerObserver == true{
                self.assigningNewStatusColor()
            }
            
            
        }
        completion()
    }
    
    
    private func removeBillWithObserver(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        BillService.shared.removeBillObserver(uid: uid) { (bill) in
            self.totalBill -= Int(bill.price)!
            if bill.repetition == 0{
                self.totalFixedBill -= Int(bill.price)!
            }
            
            self.assigningTotalBillValueBlock()
            
            if self.triggerObserver == true{
                self.assigningNewStatusColor()
            }
            
            return
        }
    }
    
    private func retrieveInstantBillWithObserver(completion: @escaping() -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        BillService.shared.fetchInstantBillObserver(uid: uid) { (bill) in
            self.totalBill = self.totalBill + Int(bill.price)!
            self.assigningTotalBillValueBlock()
        }
        completion()
    }
    
    private func removeInstantBillObserver(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        BillService.shared.removeInstantBillObserver(uid: uid) { (bill) in
            self.totalBill = self.totalBill - Int(bill.price)!
            self.assigningTotalBillValueBlock()
        }
        
    }
    
}

//MARK: - Assigning values

extension HomeViewController{
    private func configureValues(){
        
        totalEquityBlock.totalValueLabel.text = MathConver.shared.updateFormatedValue(value: Int(self.totalEquityVal)!)!
        
        addAndGoalsInfoTripleBlock?.rightValue = String(activeMonthGoals)
        addAndGoalsInfoTripleBlock?.configureUI()
        
        goalsBillBlock?.contentLabel.text = MathConver.shared.updateFormatedValue(value: self.totalGoalsBill)
        let percentGoalBill = round(Float(self.totalGoalInstallmentBill)/Float(self.monthIncomeVal)! * 100)
        goalsBillBlock?.percentValueInt = Int(percentGoalBill)
        if Int(percentGoalBill) != 30{
            self.shouldDisplayReadjustInst = true
        }else{
            self.shouldDisplayReadjustInst = false
        }
        goalsBillBlock?.configureUI()
        
        mainInfosTripleBlock?.topLeftValue = MathConver.shared.updateFormatedValue(value: Int(self.monthIncomeVal)!)!
        mainInfosTripleBlock?.bottomLeftValue = MathConver.shared.updateFormatedValue(value: self.totalFixedBill)!
        mainInfosTripleBlock?.rightValue = MathConver.shared.updateFormatedValue(value: self.totalBill)!
        let percentTotalBill = round(Float(self.totalBill)/Float(self.monthIncomeVal)! * 100)
        mainInfosTripleBlock?.percentValueInt = Int(percentTotalBill)
        mainInfosTripleBlock?.contentUpdate()
        
        configureTotalEquityBlock()
        
    }
    
    private func configureTotalEquityBlock(){
        totalEquityBlock.statusColor = statusColorInt
        totalEquityBlock.configureUI()
    }
    
    private func assigningTotalBillValueBlock(){
        mainInfosTripleBlock?.bottomLeftValue = MathConver.shared.updateFormatedValue(value: self.totalFixedBill)!
        mainInfosTripleBlock?.rightValue = MathConver.shared.updateFormatedValue(value: self.totalBill)!
        if let mnthIncome = Float(self.monthIncomeVal){
            let percentTotalBill = round(Float(self.totalBill)/mnthIncome * 100)
            mainInfosTripleBlock?.percentValueInt = Int(percentTotalBill)
        }
        
        mainInfosTripleBlock?.contentUpdate()
        configureGesturePress() //By calling configure ui, it removes the gestures rec, so added it again
    }
    
    private func assigningGoalBillValueBlock(){
        goalsBillBlock?.contentLabel.text = MathConver.shared.updateFormatedValue(value: self.totalGoalsBill)
        
        if let mnthIncome = Float(self.monthIncomeVal){
            let percentGoalBill = round(Float(self.totalGoalInstallmentBill)/mnthIncome * 100)
            goalsBillBlock?.percentValueInt = Int(percentGoalBill)
            if Int(percentGoalBill) != 30{
                self.shouldDisplayReadjustInst = true
            }else{
                self.shouldDisplayReadjustInst = false
            }
        }
        goalsBillBlock?.configureUI()
        configureGesturePress()
    }
    
    private func assigningActiveGoalsValueBlock(){
        addAndGoalsInfoTripleBlock?.rightValue = String(activeMonthGoals)
        addAndGoalsInfoTripleBlock?.configureUI()
    }
    
    private func assigningNewStatusColor(){
        comparingValues(incomeSalaryDate: monthIncomeDate, userIncome: Int(totalEquityVal)!, userSalary: Int(monthIncomeVal)!) { (intVal) in
            self.statusColorInt = intVal
            self.configureTotalEquityBlock()
        }
    }
}

//MARK: - Notification
extension HomeViewController{
    
    func notificationAuthorization(){
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
        let dailySpendingInt = calculateDailySpending(totalBillSpends: self.totalBill, totalGoalSpends: self.totalGoalInstallmentBill, monthIncome: Int(self.monthIncomeVal)!)
        let dailySpendingConverted = MathConver.shared.updateFormatedValue(value: dailySpendingInt)
        
        
        let req = displayNotification(title: "Good morning, \(userNameString)!", body: "Today’s spending recommendation: \(dailySpendingConverted!)")
        
        notificationCenter.add(req) { (error) in
            if let error = error{
                print("Error when displaying notification: \(error)")
            }
        }
    }
    
}

extension HomeViewController: GADInterstitialDelegate{
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }
    
    private func showAd(){
        if adTrigger == true{
            timer.invalidate()
            adTrigger = false
            startTimer()
        }
    }
    
    func shouldDisplayAd(){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            print("Ad wasnt ready")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
}
