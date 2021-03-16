//
//  AddBillViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 27/06/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class AddBillViewController: UIViewController, UITextFieldDelegate{
    
    //MARK: - Properties
    
    let buttonSize: CGFloat = 50
    let normalPickerSpace: CGFloat = 40
    let biggerPickerSpace: CGFloat = 60
    
    private let billNameTF = MainPickerView(title: "Bill name")
    private let billPriceTF = MainPickerView(title: "Bill price", keyboardType: .numberPad)
    private let billRepSeg = MainPickerView(isTextField: false,
                                             isSegmentedControl: true,
                                             segControlItems: ["Monthly", "Once"],
                                             shouldHaveHeader: true,
                                             headerString: "Bill repetition")
    private let billingDatePickerTF = MainPickerView(title: "Billing date")
    
    private var billNameValue = String()
    private var billPriceValue = String()
    private var billRepValue = Int()
    private var billBillingDateValue = String()

    private let contentStackHolder = UIStackView()
    private let scrollView = UIScrollView()
    
    private var billPriceAmt = 0
    
    private var billPriceNormalValue = ""
    
    private var billingDatePicker = UIDatePicker()
    
    private var monthDays: [Int] = [Int]()
    
    var homeViewController: UIViewController?
    
    var addedNotification: NotificationView?
    var notificationTrigger: Bool = true
    
    var adTrigger: Bool = Bool()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    //MARK: - Selector
    @objc private func handleDismiss(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDone(){
        definingBillData()
        uploadBill(name: billNameValue,
                   price: billPriceNormalValue,
                   repetition: billRepValue,
                   billingDate: billBillingDateValue,
                   view: self,
                   homeViewController: homeViewController!)
    }
    
    @objc private func handleToolbarDone(){
        if billRepSeg.segControl.selectedSegmentIndex == 0{
            guard let dateValue = billingDatePickerTF.tf.text else {return}
            if billingDatePickerTF.tf.text!.isEmpty{
                billingDatePickerTF.tf.text = "1"
                billBillingDateValue = billingDatePickerTF.tf.text!
            }else{
                billBillingDateValue = dateValue
            }
            
        }else{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            
            billingDatePickerTF.tf.text = formatter.string(from: billingDatePicker.date)
            
            let toStringDateForm = DateFormatter()
            toStringDateForm.dateFormat = "yyyy-MM-dd"
            billBillingDateValue = toStringDateForm.string(from: billingDatePicker.date)
        }
        
        
        self.view.endEditing(true)
    }
    
    @objc private func handleSegmentedChange(){
        if billRepSeg.segControl.selectedSegmentIndex == 0{
            configurePickerView()
        }else{
            configureBillingDatePicker()
        }
        billingDatePickerTF.tf.text = ""
        billBillingDateValue = ""
        self.view.endEditing(true)
    }
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }

    //MARK: - Helper functions
    
    private func configure(){
        configureNavBar()
        configureDelegate()
        configureUI()
        configureSegmentedControl()
        configurePickerView()
        configureDismissKeyboard()
    }
    
    private func configureNavBar(){
        navigationItem.title = "Add bill"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    private func configureDelegate(){
        billPriceTF.tf.delegate = self
    }
    
    private func configureUI(){
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        scrollView.frame.size = view.frame.size
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
        
        contentStackHolder.layoutMargins = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        contentStackHolder.layoutIfNeeded()
        
        contentStackHolder.addArrangedSubview(billNameTF)
        contentStackHolder.addArrangedSubview(billPriceTF)
        contentStackHolder.addArrangedSubview(billRepSeg)
        contentStackHolder.addArrangedSubview(billingDatePickerTF)
        
        billNameTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        billPriceTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        billRepSeg.heightAnchor.constraint(equalToConstant: biggerPickerSpace).isActive = true
        billingDatePickerTF.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
    }
    
    private func definingBillData(){
        billNameValue = billNameTF.tf.text!
        billPriceValue = billPriceTF.tf.text!
        billRepValue = billRepSeg.segControl.selectedSegmentIndex
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == billPriceTF.tf{
            
            billPriceNormalValue = billPriceNormalValue + string
            
            
            if let digit = Int(string){
                billPriceAmt = billPriceAmt * 10 + digit
                
                if billPriceAmt > 1_000_000_000_00{
                    standardAlert(title: "Please, enter a value less than 1 billion")
                    billPriceAmt = 0
                    billPriceNormalValue = ""
                    billPriceTF.tf.text = ""
                }else{
                    billPriceTF.tf.text = MathConver.shared.updateFormatedValue(value: billPriceAmt)
                }
                
            }

            if string == ""{
                billPriceAmt = billPriceAmt/10
                billPriceTF.tf.text = billPriceAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: billPriceAmt)
                
                billPriceNormalValue = String(billPriceNormalValue.dropLast())
            }
            
            print(billPriceNormalValue)
        }
        return false
    }
    
    
    private func configureBillingDatePicker(){
        //Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(handleToolbarDone))
        toolbar.setItems([doneBtn], animated: true)
        
        billingDatePickerTF.tf.inputAccessoryView = toolbar
        
        billingDatePickerTF.tf.inputView = billingDatePicker
        
        billingDatePicker.datePickerMode = .date
    }
    
    private func configureSegmentedControl(){
        billRepSeg.segControl.addTarget(self, action: #selector(handleSegmentedChange), for: .valueChanged)
    }
    
}

extension AddBillViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    private func createDaysArray(){
        for i in 1...31{
            monthDays.append(i)
        }
    }
    
    private func configurePickerView(){
        createDaysArray()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleToolbarDone))
        toolbar.setItems([doneButton], animated: true)
        
        billingDatePickerTF.tf.inputAccessoryView = toolbar
        
        let datePickerView = UIPickerView()
        datePickerView.delegate = self
        datePickerView.dataSource = self
        billingDatePickerTF.tf.inputView = datePickerView
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
        billingDatePickerTF.tf.text = String(monthDays[row])
        billBillingDateValue = String(monthDays[row])
    }
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

//MARK: - Loading View

extension AddBillViewController{
    
    func addSendLoading(){
        let loadingView = LoadingFullSizeView()
        view.addSubview(loadingView)
        
        loadingView.frame = view.frame
    }
    
}

//MARK: - Animations

extension AddBillViewController{
    
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
