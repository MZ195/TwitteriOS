//
//  Post.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/20/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit

class Post: NSObject {
    var username:String?
    var postContent:String?
    var userImage:String?
    
    init(userName:String, content:String, img:String?) {
        self.username = userName
        self.postContent = content
        self.userImage = img
    }
}
