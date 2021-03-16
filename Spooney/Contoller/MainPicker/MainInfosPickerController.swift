//
//  MainInfosPickerController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class MainInfosPickerController: LBTAFormController, UITextFieldDelegate{
    
    //MARK: - Properties
    
    let buttonSize: CGFloat = 50
    let normalPickerSpace: CGFloat = 40
    let biggerPickerSpace: CGFloat = 60
    
    private let firstNameTF = MainPickerView(title: "First name")
    private let lastNameTF = MainPickerView(title: "Last name")
    private let monthIncomeTF = MainPickerView(title: "Monthly income", keyboardType: .numberPad)
    private let dateIncomeTF = MainPickerView(title: "Day", shouldHaveHeader: true, headerString: "Month income receiving day")
    private let totalEquityTF = MainPickerView(title: "Total equity", keyboardType: .numberPad)
    
    private let addGoalButton: UIButton = UIButton().standardButtonLayout(title: "Add goal", color: .customSystemBlue)
    private let addBillButton: UIButton = UIButton().standardButtonLayout(title: "Add bill", color: .customSystemGreen)
    private let continueButton = LoadingButton()
    
    private var monthIncomeAmt = 0
    private var totalEquityAmt = 0
    
    private var monthIncomeNormalValue = ""
    private var dateIncomeNormalValue = "1"
    private var totalEquityNormalValue = ""
    
    private var monthDays: [Int] = [Int]()
    
    var addedNotification: NotificationView?
    
    var notificationTrigger: Bool = true
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - Selector
    
    @objc private func handleAddGoal(){
        presentAddGoal(view: self, goalsPriorityArray: [], userMonthInc: 0)
    }
    
    @objc private func handleAddBill(){
        presentAddBills(view: self)
    }
    
    @objc private func handleContinue(){
        uploadingUserData()
    }
    
    @objc private func handleDoneMonthIncomeDay(){
        if dateIncomeTF.tf.text!.isEmpty{
            dateIncomeNormalValue = "1"
            dateIncomeTF.tf.text = "1"
        }else{
            dateIncomeNormalValue = dateIncomeTF.tf.text!
        }
        self.view.endEditing(true)
    }
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }
    //MARK: - Helper functions
    
    private func configure(){
        view.backgroundColor = .white
        configureDelegates()
        configureNavBar()
        configureUI()
        configurePickerView()
        configureDismissKeyboard()
    }
    
    private func configureDelegates(){
        monthIncomeTF.tf.delegate = self
        totalEquityTF.tf.delegate = self
    }
    
    private func configureNavBar(){
        navigationItem.title = "Initial data"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureUI(){
        let stack = formContainerStackView
        stack.axis = .vertical
        stack.spacing = 25
        stack.layoutMargins = .init(top: 25, left: 16, bottom: 34, right: 16)
        
        
        stack.addArrangedSubview(firstNameTF)
        stack.addArrangedSubview(lastNameTF)
        stack.addArrangedSubview(monthIncomeTF)
        stack.addArrangedSubview(dateIncomeTF)
        stack.addArrangedSubview(totalEquityTF)
        
        stack.addArrangedSubview(addGoalButton)
        stack.addArrangedSubview(addBillButton)
        continueButton.standardButton(title: "Continue")
        stack.addArrangedSubview(continueButton)
        
        stack.setCustomSpacing(40, after: addBillButton)
        
        firstNameTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        lastNameTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        monthIncomeTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        dateIncomeTF.heightAnchor.constraint(equalToConstant: biggerPickerSpace).isActive = true
        totalEquityTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        
        addGoalButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        addBillButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        addGoalButton.addTarget(self, action: #selector(handleAddGoal), for: .touchUpInside)
        addBillButton.addTarget(self, action: #selector(handleAddBill), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
    }
    
    private func uploadingUserData(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["firstName": firstNameTF.tf.text!,
                      "lastName": lastNameTF.tf.text!,
                      "monthIncome": monthIncomeNormalValue,
                      "incomeDate": dateIncomeNormalValue,
                      "totalEquity": totalEquityNormalValue] as [String : Any]
        
        for field in values{
            if field.value as! String == ""{
                if notificationTrigger == true{
                    presentNotification(type: 0)
                }
                return
            }
        }
        
        continueButton.setTitle("Finishing", for: .normal)
        continueButton.loadIndicator(true)
        
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            if let error = error{
                print("new error \(error)")
                return
            }

            let controller = UINavigationController(rootViewController: HomeViewController())
            self.presentDetailFromRight(controller)

        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == monthIncomeTF.tf{
            monthIncomeNormalValue += string
            
            if let digit = Int(string){
                monthIncomeAmt = monthIncomeAmt * 10 + digit
                monthIncomeTF.tf.text = MathConver.shared.updateFormatedValue(value: monthIncomeAmt)
            }
            
            if string == ""{
                monthIncomeAmt = monthIncomeAmt/10
                monthIncomeTF.tf.text = monthIncomeAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: monthIncomeAmt)
                monthIncomeNormalValue = String(monthIncomeNormalValue.dropLast())
            }
            
        }else{
            totalEquityNormalValue += string
            if let digit = Int(string){
                totalEquityAmt = totalEquityAmt * 10 + digit
                totalEquityTF.tf.text = MathConver.shared.updateFormatedValue(value: totalEquityAmt)
            }
            
            if string == ""{
                totalEquityAmt = totalEquityAmt/10
                totalEquityTF.tf.text = totalEquityAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: totalEquityAmt)
                totalEquityNormalValue = String(totalEquityNormalValue.dropLast())
            }
        }
        return false
    }
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}

extension MainInfosPickerController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    private func createDaysArray(){
        for i in 1...31{
            monthDays.append(i)
        }
    }
    
    private func configurePickerView(){
        createDaysArray()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneMonthIncomeDay))
        toolbar.setItems([doneButton], animated: true)
        
        dateIncomeTF.tf.inputAccessoryView = toolbar
        
        let datePickerView = UIPickerView()
        datePickerView.delegate = self
        dateIncomeTF.tf.inputView = datePickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return monthDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(monthDays[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateIncomeTF.tf.text = String(monthDays[row])
        dateIncomeNormalValue = String(monthDays[row])
    }
    
    
    func presentNotification(type: Int){
        notificationTrigger = false
        //0 = error 1 = bill added 2 = goal added
        if type == 0{
            addedNotification = NotificationView(type: 2, view: view, color: .customSystemRed)
            addedNotification?.textContent.text = "Fill all the fields"
        }else{
            addedNotification = NotificationView(type: 2, view: view)
            if type == 1{
                addedNotification?.textContent.text = "Bill added"
            }else{
                addedNotification?.textContent.text = "Goal added"
            }
        }
        
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(addedNotification!)
        addedNotification!.configureUI()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.addedNotification?.holder.frame.origin.y = 40
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
