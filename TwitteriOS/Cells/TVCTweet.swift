//
//  TVCTweet.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/19/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class TVCTweet: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UITextView!
    let reffStor = Storage.storage().reference(forURL: "gs://twitterapp-52392.appspot.com/")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAttributes(post: Post){
        username.text = post.username!
        content.text = post.postContent!
        
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        
        let profileUrl = post.userImage
        
        if profileUrl != ""{
            self.reffStor.child(profileUrl!).downloadURL(completion: { (url, error) in
                if let err = error {
                    print(err)
                }else{
                    let url = URL(string: (url?.absoluteString)!)
                    
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if let err = error {
                            print(err)
                        }
                        DispatchQueue.main.async {
                            self.userImage.image = UIImage(data: data!)
                            
                        }
                    }).resume()
                }
            });
        }else {
            userImage.image = UIImage(named: "twitter_icon")
        }
    }
}
