//
//  NewPostViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/20/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class NewPostViewController: UIViewController {
    
    var fireStoreDatabaseRef = Firestore.firestore()
    var databaseRef = DatabaseReference.init()
    var userID:String?
    var username:String?
    
    @IBOutlet weak var postContent: UITextView!
    
    @IBOutlet weak var postButton: UIButton!{
        didSet{
            postButton.addTarget(self, action: #selector(handelNewPost), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet{
            dismissButton.addTarget(self, action: #selector(handelDismiss), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        userID = Auth.auth().currentUser?.uid
        username = Auth.auth().currentUser?.displayName
        // Do any additional setup after loading the view.
    }
    
    @objc func handelDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handelNewPost() {
        
        let postDetails = ["uid" : userID,
                           "author": username,
                           "content" : postContent.text,
            "Date" : ServerValue.timestamp()] as [String : Any]

        var ref:DocumentReference? = nil
        ref = self.fireStoreDatabaseRef.collection("Posts").addDocument(data: postDetails){
            error in
            
            if let error = error {
                print("Error adding document \(error)")
            }else{
                print("Document inserted successfully with ID: \(ref!.documentID)")
                self.databaseRef.child("Timeline").child(self.userID!).child("\(ref!.documentID)").setValue(postDetails)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }

}
