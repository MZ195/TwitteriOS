//
//  ViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/9/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func upLoadImage(_ sender: Any) {
    }
    
    @IBAction func login(_ sender: Any) {
    }
    
    @IBAction func register(_ sender: Any) {
        let email = self.email.text
        let password = self.password.text
        
        Auth.auth().createUser(withEmail: email!, password: password!){
            // this method returns a user or error
            (user, error) in
            if let error = error {
                print(error)
            } else {
                print(user?.additionalUserInfo?.providerID)
            }
        }
    }
    
}

