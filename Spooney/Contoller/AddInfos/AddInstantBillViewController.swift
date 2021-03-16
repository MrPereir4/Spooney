//
//  AddInstantBillViewController.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 01/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

class AddInstantBillViewController: UIViewController, UITextFieldDelegate{
    //MARK: - Properties
    
    let categories = ["Market", "Education", "Family", "Expenses", "Leisure", "Travel", "Fixes", "Food", "Transport"]
    
    let buttonSize: CGFloat = 50
    let normalPickerSpace: CGFloat = 40
    let biggerPickerSpace: CGFloat = 60
    
    private var insName = MainPickerView(title: "Bill name")
    private var insPrice = MainPickerView(title: "Bill price", keyboardType: .numberPad)
    private var insCategory = MainPickerView(title: "Category")
    
    private var intBillPriceAmt = 0
       
    private var recNameValue = String()
    private var recPriceNormalValue = ""
    private var recBillingDateValue = String()
    
    private var contentStackHolder = UIStackView()
    private var scrollView = UIScrollView()
    
    var fromViewController: UIViewController?
    
    var categorySelected: Int = -1
    
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDone(){
        recNameValue = insName.tf.text!
        uploadReceipt(name: recNameValue,
                      price: recPriceNormalValue,
                      category: categorySelected,
                      view: self,
                      fromController: fromViewController!)
    }
    
    @objc private func handleToolbarDone(){
        if insCategory.tf.text == ""{
            insCategory.tf.text = categories[0]
            categorySelected = 0
        }
        
        self.view.endEditing(true)
    }

    //MARK: - Helper functions
    
    private func configureNavBar(){
        navigationItem.title = "Instant bill"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }
    
    private func configure(){
        configureNavBar()
        configureDelegate()
        configureUI()
        configureScrollHeight()
        configureDismissKeyboard()
        configurePickerView()
    }
    
    private func configureDelegate(){
        insPrice.tf.delegate = self
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
        
        contentStackHolder.addArrangedSubview(insName)
        contentStackHolder.addArrangedSubview(insPrice)
        contentStackHolder.addArrangedSubview(insCategory)
        
        insName.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        insPrice.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
        insCategory.heightAnchor.constraint(equalToConstant: normalPickerSpace).isActive = true
    }
    
    private func configureScrollHeight(){
        contentStackHolder.layoutIfNeeded()
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        let safeAreas = (window?.safeAreaInsets.bottom)! + 8
        
        if contentStackHolder.frame.height > view.frame.height - safeAreas{
            scrollView.contentSize.height = contentStackHolder.frame.height + safeAreas
        }
    }
    
    
    private func configureDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}

//MARK: - Text field config

extension AddInstantBillViewController{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == insPrice.tf{
            
            recPriceNormalValue = recPriceNormalValue + string
            
            
            if let digit = Int(string){
                intBillPriceAmt = intBillPriceAmt * 10 + digit
                
                if intBillPriceAmt > 1_000_000_000_00{
                    standardAlert(title: "Please, enter a value less than 1 billion")
                    intBillPriceAmt = 0
                    recPriceNormalValue = ""
                    insPrice.tf.text = ""
                }else{
                    insPrice.tf.text = MathConver.shared.updateFormatedValue(value: intBillPriceAmt)
                }
                
            }

            if string == ""{
                intBillPriceAmt = intBillPriceAmt/10
                insPrice.tf.text = intBillPriceAmt == 0 ? "" : MathConver.shared.updateFormatedValue(value: intBillPriceAmt)
                
                recPriceNormalValue = String(recPriceNormalValue.dropLast())
            }
            
            print(recPriceNormalValue)
        }
        return false
    }
}

//MARK: - Loading View

extension AddInstantBillViewController{
    
    func addSendLoading(){
        let loadingView = LoadingFullSizeView()
        view.addSubview(loadingView)
        
        loadingView.frame = view.frame
    }
    
}

//MARK: - Animations

extension AddInstantBillViewController{
    
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

//MARK: - PickerView

extension AddInstantBillViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    private func configurePickerView(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleToolbarDone))
        toolbar.setItems([doneButton], animated: true)
        
        insCategory.tf.inputAccessoryView = toolbar
        
        let categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        insCategory.tf.inputView = categoryPickerView
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        insCategory.tf.text = categories[row]
        categorySelected = row
    }
    
}
