//
//  NewPostViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/20/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class NewPostViewController: UIViewController {
    
    var databaseRef = DatabaseReference.init()
    var userUID:String?
    
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var postButton: UIButton!{
        didSet{
            dismissButton.addTarget(self, action: #selector(handelNewPost), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet{
            dismissButton.addTarget(self, action: #selector(handelDismiss), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func handelDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handelNewPost() {
        databaseRef = Database.database().reference()
        databaseRef.child("Timeline").child(self.userUID!)
        self.dismiss(animated: true, completion: nil)
    }

}
