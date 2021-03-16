//
//  AddGoalViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//


import UIKit
import LBTATools

class AddGoalViewController: LBTAFormController, UITextFieldDelegate{
    
    //MARK: - Properties
    let types = ["Car", "House", "Marriage", "Smartphone", "Education", "Entertainment", "My Business", "Motorcycle", "Gift", "Product", "Travel", "Other"]
    
    let buttonSize: CGFloat = 50
    let normalPickerSpace: CGFloat = 40
    let biggerPickerSpace: CGFloat = 60
    
    private let goalNameTf = MainPickerView(title: "Goal name")
    private let goalPriceTf = MainPickerView(title: "Goal price", keyboardType: .numberPad)
    private let goalPriority = MainPickerView(isTextField: false,
                                              isSegmentedControl: true,
                                              segControlItems: ["Low", "Medium", "High"],
                                              shouldHaveHeader: true,
                                              headerString: "Goal priority")
    private let goalType = MainPickerView(title: "Goal type")
    private let expDate = MainPickerView(title: "Date", shouldHaveHeader: true, headerString: "Goal expiration date")
    private let monthIns = MainPickerView(title: "$0", isTextField: true, keyboardType: .numberPad, shouldHaveHeader: true, headerString: "Monthly installment")
    
    
    private var goalNameValue = String()
    private var goalPriceValue = String()
    private var goalPriorityValue = Int()
    private var goalTypeValue = String()
    private var goalExpDateValue = String()
    private var goalmonthInsValue = String()
    
    var allGoalsPriority: [Int] = [Int]()
    var userMonthInc: Int = Int()
    
    private var goalPriceAmt = 0
    private var goalmonthInsAmt = 0
    
    private var goalPriceNormalValue = ""
    private var goalmonthInsNormalValue = ""
    
    private var goalTypeSelected: Int = -1
    
    private var expDatePicker = UIDatePicker()
    
    private var addedNotification: NotificationView?
    
    var homeViewController: UIViewController?

    var notificationTrigger: Bool = true
    
    var adTrigger: Bool = Bool()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    //MARK: - Seletor
    
    @objc private func handleDismiss(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }

    @objc private func handleDone(){
        definingGoalData()
        print(goalmonthInsAmt)
        uploadAddGoal(name: goalNameValue,
                      price: goalPriceValue,
                      priority: goalPriorityValue, //Converting to a validate in the next step inside uploadAddGoal
                      type: goalTypeSelected,
                      expDate: goalExpDateValue,
                      installment: goalmonthInsValue,
                      view: self,
                      homeViewController: homeViewController!)
    }
    
    @objc private func handleToolbarDone(){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        expDate.tf.text = formatter.string(from: expDatePicker.date)
        
        let toStringDateForm = DateFormatter()
        toStringDateForm.dateFormat = "yyyy-MM-dd"
        goalExpDateValue = toStringDateForm.string(from: expDatePicker.date)
        
        self.view.endEditing(true)
    }
    
    @objc private func handlePickerViewToolbarDone(){
        if goalType.tf.text == ""{
            goalType.tf.text = types[0]
            goalTypeSelected = 0
        }
        
        self.view.endEditing(true)
    }
    //MARK: - Helper functions
    private func configure(){
        print()
        configureDelegate()
        configureNavBar()
        configureUI()
        configureExtDatePicker()
        configureDismissKeyboard()
        configurePickerView()
        configureSegControlTarget()
    }
    
    private func configureDelegate(){
        goalPriceTf.tf.delegate = self
        monthIns.tf.delegate = self
    }
    
    private func configureNavBar(){
        navigationItem.title = "Add goal"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    private func configureUI(){
        let stack = formContainerStackView
        stack.axis = .vertical
        stack.spacing = 25
        stack.layoutMargins = .init(top: 25, left: 16, bottom: 0, right: 16)
        
        stack.addArrangedSubview(goalNameTf)
        stack.addArrangedSubview(goalPriceTf)
        stack.addArrangedSubview(goalPriority)
        stack.addArrangedSubview(goalType)
        stack.addArrangedSubview(expDate)
        stack.addArrangedSubview(monthIns)
        
        goalNameTf.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        goalPriceTf.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        goalPriority.heightAnchor.constraint(equalToConstant: biggerPickerSpace).isActive = true
        goalType.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        expDate.heightAnchor.constraint(equalToConstant: biggerPickerSpace).isActive = true
        monthIns.heightAnchor.constraint(equalToConstant: biggerPickerSpace).isActive = true
    }
    
    private func definingGoalData(){
        print(goalmonthInsNormalValue)
        goalNameValue = goalNameTf.tf.text!
        goalPriceValue = goalPriceNormalValue
        goalPriorityValue = goalPriority.segControl.selectedSegmentIndex
        goalTypeValue = goalType.tf.text!
        goalmonthInsValue = goalmonthInsNormalValue
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == goalPriceTf.tf{
            
            
            if (homeViewController?.isKind(of: HomeViewController.self))!{
                callForCalculateInstallment()
            }
            
            goalPriceNormalValue = goalPriceNormalValue + string
            
            
            if let digit = Int(string){
                goalPriceAmt = goalPriceAmt * 10 + digit
                
                if goalPriceAmt > 1_000_000_000_00{
                    standardAlert(title: "Please, enter a value less than 1 billion")
                    goalPriceAmt = 0
                    goalPriceNormalValue = ""
                    goalPriceTf.tf.text = ""
                }else{
                    goalPriceTf.tf.text = MathConver.shared.updateFormatedValue(value: goalPriceAmt)
                }
            }

            if string == ""{
                goalPriceAmt = goalPriceAmt/10
                goalPriceTf.tf.text = goalPriceAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: goalPriceAmt)
                
                goalPriceNormalValue = String(goalPriceNormalValue.dropLast())
            }
            
        }else{
            if (monthIns.tf.text?.isEmpty)!{
                goalmonthInsNormalValue = ""
            }
            goalmonthInsNormalValue = goalmonthInsNormalValue + string
            print(goalmonthInsNormalValue)
            if let digit = Int(string){
                goalmonthInsAmt = goalmonthInsAmt * 10 + digit
                
                if goalmonthInsAmt > 1_000_000_000_00{
                    standardAlert(title: "Please, enter a value less than 1 billion")
                    goalmonthInsAmt = 0
                    goalmonthInsNormalValue = ""
                    monthIns.tf.text = ""
                }else{
                    monthIns.tf.text = MathConver.shared.updateFormatedValue(value: goalmonthInsAmt)
                }
                
            }

            if string == ""{
                goalmonthInsAmt = goalmonthInsAmt/10
                monthIns.tf.text = goalmonthInsAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: goalmonthInsAmt)
                goalmonthInsNormalValue = String(goalmonthInsNormalValue.dropLast())
            }
            
        }
        
        return false
    }
    
    
    private func configureExtDatePicker(){
        
        //Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleToolbarDone))
        toolbar.setItems([doneBtn], animated: true)
        
        expDate.tf.inputAccessoryView = toolbar
        
        expDate.tf.inputView = expDatePicker
        
        expDatePicker.datePickerMode = .date
    }
    
    private func configureSegControlTarget(){
        goalPriority.segControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}

//MARK: - Loading View

extension AddGoalViewController{
    
    func addSendLoading(){
        let loadingView = LoadingFullSizeView()
        view.addSubview(loadingView)
        
        loadingView.frame = view.frame
    }
    
}

//MARK: - Animations

extension AddGoalViewController{
    
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



extension AddGoalViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    private func configurePickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handlePickerViewToolbarDone))
        toolbar.setItems([doneButton], animated: true)
        
        goalType.tf.inputAccessoryView = toolbar
        
        let categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        goalType.tf.inputView = categoryPickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        goalType.tf.text = types[row]
        goalTypeSelected = row
    }
      
}


extension AddGoalViewController{
    
    @objc private func segmentedControlValueChanged(){
        callForCalculateInstallment()
    }
    
    @objc private func callForCalculateInstallment(){
        goalmonthInsNormalValue = ""
        
        if !(goalPriceTf.tf.text?.isEmpty)!{
            let goalP = goalPriority.segControl.selectedSegmentIndex
            print(goalP)
            print(allGoalsPriority)
            let mnIntall = calculateMonthInstallment(percentageAvaliable: 30, userMntIncome: userMonthInc, goalPriority: goalP, allGoals: allGoalsPriority)
            
            let convertedCalculateValue = MathConver.shared.updateFormatedValue(value: mnIntall)
            
            monthIns.tf.text = convertedCalculateValue
            goalmonthInsNormalValue = String(mnIntall)
        }
    }
}
