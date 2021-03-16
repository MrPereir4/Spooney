//
//  Alert.swift
//  Spooney
//
//  Created by Vinnicius Pereira on 17/07/20.
//  Copyright © 2020 Vinnicius Pereira. All rights reserved.
//

import UIKit

extension UIViewController {
    func standardAlert(message: String = "", title: String = ""){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
