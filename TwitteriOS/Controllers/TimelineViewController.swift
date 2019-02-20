//
//  TimelineViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/19/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var postsTable: UITableView!
    var userUID:String?
    var posts = [Post]()
    var databaseRef = DatabaseReference.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTable.delegate = self
        postsTable.dataSource = self
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
