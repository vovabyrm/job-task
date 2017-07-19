//
//  post.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 18.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import SwiftyJSON

class PHPost {
    var name : String //name
    var thumbnailURL : URL? //thumbnail -> image_url
    var screenshotURL : URL? //screenshot_url -> 300px(850px)
    var openURL : URL? //redirect_url
    var votesCount : Int //votes_count
    var description : String //tagline
    
    init(response : JSON) {
        self.name = response["name"].stringValue
        self.description = response["tagline"].stringValue
        self.votesCount = response["votes_count"].intValue
        
        let urlString = response["redirect_url"].stringValue
        self.openURL = URL(string: urlString)
        
        let thumbnailURLString = response["thumbnail"]["image_url"].stringValue
        let thumbnail = thumbnailURLString.components(separatedBy: "?")
        self.thumbnailURL = URL(string: thumbnail[0])
        
        let screenshotURLstring = response["screenshot_url"]["850px"].stringValue
        self.screenshotURL = URL(string: screenshotURLstring)
        
    }
}


