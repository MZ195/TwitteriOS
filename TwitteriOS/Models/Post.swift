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
    var userimage:String?
    var postContent:String?
    
    init(userName:String, img:String, content:String) {
        self.username = userName
        self.userimage = img
        self.postContent = content
    }
}
