//
//  TimelineViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/19/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
   
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var roundButton:UIButton!
    
    var posts = [Post]()
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTable.delegate = self
        postsTable.dataSource = self
        
        self.roundButton.setTitleColor(UIColor.orange, for: .normal)
        self.roundButton.layer.cornerRadius = roundButton.layer.frame.size.width/2
        self.view.addSubview(self.roundButton)
        
        db = Firestore.firestore()
        loadData()
        checkForUpdate()
    }
    
    func loadData() {
        db.collection("Posts").getDocuments(){
            QuerySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.posts = (QuerySnapshot?.documents.flatMap({Post(userName: $0.data()["author"] as! String, content: $0.data()["content"] as! String)}))!
                DispatchQueue.main.async {
                    self.postsTable.reloadData()
                }
            }
        }
    }
    
    func checkForUpdate() {
        db.collection("Posts").whereField("Date", isGreaterThan: Date())
            .addSnapshotListener { QuerySnapshot, Error in
                if let error = Error {
                    print("\(error.localizedDescription)")
                }else{
                    guard let snapshot = QuerySnapshot else {return }
                    
                    snapshot.documentChanges.forEach({ (DocumentChange) in
                        if DocumentChange.type == .added {
                            self.posts.append(Post(userName: DocumentChange.document.data()["author"] as! String, content: DocumentChange.document.data()["content"] as! String))
                            DispatchQueue.main.async {
                                self.postsTable.reloadData()
                            }
                        }
                    })
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTable.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TVCTweet
        cell.setAttributes(post: posts[indexPath.row])
        return cell
    }
}
