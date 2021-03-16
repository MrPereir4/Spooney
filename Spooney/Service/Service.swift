//
//  Service.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 06/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import Firebase

//MARK: - DatabaseRefs

let uid = Auth.auth().currentUser?.uid

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_GOALS = DB_REF.child("goals")
let REF_BILLS = DB_REF.child("bills")
let REF_INSBILLS = DB_REF.child("instBill")


struct UserService {
    static let shared = UserService()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void){
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUserGoals(uid: String, completion: @escaping(DataSnapshot) -> Void){
        REF_GOALS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    func fetchUserBills(uid: String, completion: @escaping(DataSnapshot) -> Void){
        REF_BILLS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    func fetchUserInsBills(uid: String, completion: @escaping(DataSnapshot) -> Void){
        REF_INSBILLS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    func userDataObserver(uid: String, completion: @escaping(DataSnapshot) -> Void){
        REF_USERS.child(uid).observe(.childChanged) { (snapshot) in
            completion(snapshot)
        }
    }
}


//Add bills
func presentAddBills(view: UIViewController){
    let root = AddBillViewController()
    var convHomeView: HomeViewController!
    if view.isKind(of: HomeViewController.self){
        convHomeView = view as? HomeViewController
        root.adTrigger = convHomeView.adTrigger
    }
    root.homeViewController = view
    let nav = UINavigationController(rootViewController: root)
    nav.modalPresentationStyle = .formSheet
    view.present(nav, animated: true, completion: nil)
}

//Add goals
func uploadBill(name: String, price: String, repetition: Int, billingDate: String, view: UIViewController, homeViewController: UIViewController){
    // 0 = home 1 = infoPicker
    guard let uid = uid else {return}
    let view = view as! AddBillViewController
    let values = ["name": name,
                  "price": price,
                  "repetition": repetition,
                  "billingDate": billingDate] as [String: Any]
    
    for field in values.values{
        if field is String{
            if (field as! String).isEmpty {
                view.presentNotification(type: 0)
                return
            }
        }
    }
    
    view.addSendLoading()
    
    if let billUID = REF_BILLS.childByAutoId().key{
        REF_BILLS.child(uid).child(billUID).updateChildValues(values) { (error, ref) in
            if let error = error{
                print("new error\(error)")
                return
            }
            
            if homeViewController.isKind(of: MainInfosPickerController.self){
                let homeVC = homeViewController as! MainInfosPickerController
                homeVC.presentNotification(type: 1)
            }else if homeViewController.isKind(of: HomeViewController.self){
                let homeVC = homeViewController as! HomeViewController
                homeVC.presentNotification(type: 1)
            }
            
            
            
            
            view.navigationController?.dismiss(animated: true, completion: {
                if view.adTrigger == true{
                    let convView = homeViewController as! HomeViewController
                    convView.shouldDisplayAd()
                }
            })
        }
    }
    
}

func deleteBill(billUid: String, view: UIViewController, billCode: Int){
    guard let uid = uid else {return}
    let view = view as! DisplayBillsViewController
    let refToBills = REF_BILLS.child(uid).child(billUid)
    let refToInstBill = REF_INSBILLS.child(uid).child(billUid)
    
    if billCode == 0{
        refToBills.removeValue { (error, ref) in
            if let error = error{
                print(error)
                return
            }
            
            view.presentNotification(type: 0)
            return
        }
    }else{
        refToInstBill.removeValue { (error, ref) in
            if let error = error{
                print(error)
                return
            }
            
            view.presentNotification(type: 0)
            return
        }
    }
    
}

func presentAddGoal(view: UIViewController, goalsPriorityArray: [Int], userMonthInc: Int){
    let root = AddGoalViewController()
    var convHomeView: HomeViewController!
    if view.isKind(of: HomeViewController.self){
        convHomeView = view as? HomeViewController
        root.adTrigger = convHomeView.adTrigger
    }
    root.homeViewController = view
    root.allGoalsPriority = goalsPriorityArray
    root.userMonthInc = userMonthInc
    let nav = UINavigationController(rootViewController: root)
    nav.modalPresentationStyle = .formSheet
    view.present(nav, animated: true, completion: nil)
}

func uploadAddGoal(name: String, price: String, priority: Int, type: Int, expDate: String, installment: String, view: UIViewController, homeViewController: UIViewController){
    guard let uid = uid else {return}
    let view = view as! AddGoalViewController
    let values = ["name": name,
                  "price": price,
                  "priority": priority,
                  "type": type,
                  "expDate": expDate,
                  "installment": installment] as [String: Any]
    
    for field in values.values{
        if field is String{
            if (field as! String).isEmpty {
                view.presentNotification(type: 0)
                return
            }
        }
        
        if field is Int{
            if (field as! Int) == -1{
                view.presentNotification(type: 0)
                return
            }
        }
    }
    
    view.addSendLoading()
    
    if let goalUID = REF_GOALS.childByAutoId().key{

        REF_GOALS.child(uid).child(goalUID).updateChildValues(values) { (error, ref) in
            if let error = error{
                print("new error \(error)")
            }

            if homeViewController.isKind(of: MainInfosPickerController.self){
                let homeVC = homeViewController as! MainInfosPickerController
                homeVC.presentNotification(type: 2)
            }else if homeViewController.isKind(of: HomeViewController.self){
                let homeVC = homeViewController as! HomeViewController
                homeVC.presentNotification(type: 0)
            }
            
            
            view.navigationController?.dismiss(animated: true, completion: {
                if view.adTrigger == true{
                    let convView = homeViewController as! HomeViewController
                    convView.shouldDisplayAd()
                }
            })
        }
    }
}

func deleteGoal(goalUid: String, view: UIViewController){
    guard let uid = uid else {return}
    let view = view as! DisplayGoalsViewController
    let ref = REF_GOALS.child(uid).child(goalUid)
    
    ref.removeValue { (error, ref) in
        if let error = error{
            print(error)
            return
        }
        view.presentNotification(type: 0)
        return
    }
}

func uploadReceipt(name: String, price: String, category: Int, view: UIViewController, fromController: UIViewController){
    guard let uid = uid else {return}
    let view = view as! AddInstantBillViewController
    let values = ["name": name,
                  "price": price,
                  "category": category] as [String : Any]
    
    for field in values.values{
        if field is String{
            if (field as! String).isEmpty {
                view.presentNotification(type: 0)
                return
            }
        }
        
        if field is Int{
            if (field as! Int) == -1{
               view.presentNotification(type: 0)
                return
            }
        }
    }
    
    view.addSendLoading()
    
    if let receiptUID = REF_INSBILLS.childByAutoId().key{
        REF_INSBILLS.child(uid).child(receiptUID).updateChildValues(values) { (error, ref) in
            if let error = error{
                print("New error \(error)")
            }

            if fromController.isKind(of: HomeViewController.self){
                let fCont = fromController as! HomeViewController
                fCont.presentNotification(type: 3)
            }

            view.navigationController?.dismiss(animated: true, completion: {
                if view.adTrigger == true{
                    let convView = fromController as! HomeViewController
                    convView.shouldDisplayAd()
                }
            })
        }
    }
}

//MARK: - Goal service

struct GoalService {
    static let shared = GoalService()
    
    func fetchGoalObserver(uid: String, completion: @escaping(Goal) -> Void){
        REF_GOALS.child(uid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let goal = Goal(uid: uid, dictionary: dictionary)
            completion(goal)
        }
    }
    
    func removeGoalObserver(uid: String, completion: @escaping(Goal) -> Void){
        REF_GOALS.child(uid).observe(.childRemoved) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let goal = Goal(uid: uid, dictionary: dictionary)
            completion(goal)
        }
    }
    
    func goalEditObserver(uid: String, completion: @escaping(Goal) -> Void){
        REF_GOALS.child(uid).observe(.childChanged) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let goal = Goal(uid: uid, dictionary: dictionary)
            completion(goal)
        }
    }
    
    func updateGoalValue(uid: String, newValue: Int, completion: @escaping() -> Void){
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        let value = ["installment": String(newValue)]
        REF_GOALS.child(userUID).child(uid).updateChildValues(value) { (error, ref) in
            if let error = error{
                print("There is an error: \(error)")
            }
            completion()
        }
    }
}

//MARK: - Bill service

struct BillService{
    static let shared = BillService()
    
    func fetchBillObserver(uid: String, completion: @escaping(Bill) -> Void){
        REF_BILLS.child(uid).queryOrdered(byChild: "date").queryLimited(toLast: 3).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let bill = Bill(uid: uid, dictionary: dictionary)
            completion(bill)
        }
    }
    
    func fetchBill(uid: String, completion: @escaping(DataSnapshot) -> Void){
        REF_BILLS.child(uid).queryOrdered(byChild: "date").queryLimited(toLast: 3).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot)
        })
    }
    
    func removeBillObserver(uid: String, completion: @escaping(Bill) -> Void){
        REF_BILLS.child(uid).observe(.childRemoved) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let bill = Bill(uid: uid, dictionary: dictionary)
            completion(bill)
        }
    }
    
    func fetchInstantBillObserver(uid: String, completion: @escaping(InstantBill) -> Void){
        REF_INSBILLS.child(uid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let bill = InstantBill(uid: uid, dictionary: dictionary)
            completion(bill)
        }
    }
    
    func removeInstantBillObserver(uid: String, completion: @escaping(InstantBill) -> Void){
        REF_INSBILLS.child(uid).observe(.childRemoved) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let uid = snapshot.key
            let bill = InstantBill(uid: uid, dictionary: dictionary)
            completion(bill)
        }
    }
}


struct MathConver{
    static let shared = MathConver()
    
    func updateFormatedValue(value: Int) -> String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.currencySymbol = "$"
        let amount = Double(value/100) + Double(value%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
}


struct DateConver{
    static let shared = DateConver()
    
    func convertDate(date: String, shouldHaveYear: Bool? = true) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterReturn = DateFormatter()
        dateFormatterReturn.dateFormat = "MM/dd/yyyy"
        
        let dateFormatterReturnWithoutYear = DateFormatter()
        dateFormatterReturnWithoutYear.dateFormat = "MM/dd"
        
        if shouldHaveYear == true{
            if let notConvertedDate = dateFormatterGet.date(from: date){
                return dateFormatterReturn.string(from: notConvertedDate)
            }
        }else{
            if let notConvertedDate = dateFormatterGet.date(from: date){
                return dateFormatterReturnWithoutYear.string(from: notConvertedDate)
            }
        }
        return ""
    }

}
