//
//  TVCTweet.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/19/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit

class TVCTweet: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var content: UITextView!
    
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
    }

}
