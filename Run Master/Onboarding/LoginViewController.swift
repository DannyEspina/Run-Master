//
//  LoginViewController.swift
//  Run Master
//
//  Created by Danny Espina on 1/3/19.
//  Copyright © 2019 LegendarySilverback. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet var EmailTextField: UITextField!
    @IBOutlet var PasswordTextField: UITextField!
    @IBOutlet var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func Login(_ sender: Any) {
        if let email = EmailTextField.text, let password = PasswordTextField.text {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if user != nil {
                // Go to home page
            } else {
                self.ErrorLabel.text = String(describing: error)
            }
        }
    }
}
}
