//
//  SignInViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/19/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userUID:String?
    var username:String?
    var userEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        userEmail = self.email.text
        let password = self.password.text
        Auth.auth().signIn(withEmail: userEmail!, password: password!) { (user, error) in
            if let error = error {
                print(error)
            } else {
                self.userUID = user!.user.uid
                self.performSegue(withIdentifier: "formLoginToTimeline", sender: self.userUID)
            }
        }
    }
}
