//
//  ViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/9/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController{

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var contiueButton: UIButton!
    
    var userUID:String?
    var username:String?
    var imagePath:String?
    var userEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        self.userEmail = self.email.text
        let password = self.password.text
        self.username = self.firstName.text
        
        Auth.auth().createUser(withEmail: userEmail!, password: password!){
            // this method returns a user or error
            (user, error) in
            if let error = error {
                print(error)
            } else {
                self.userUID = user!.user.uid
                self.contiueButton.isHidden = false
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ProfileImageViewController
        {
            print("userID = \(userUID)\nusername = \(username)\nuseremail = \(userEmail)")
            let vc = segue.destination as? ProfileImageViewController
            vc!.userEmail = self.userEmail
            vc!.username = self.username
            vc!.userUID = self.userUID
        }
    }
}

