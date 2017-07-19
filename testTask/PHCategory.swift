//
//  PHCategory.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 19.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import Foundation
import SwiftyJSON

class PHCategory {
    var name : String
    var slug : String
    
    init(response : JSON) {
        self.name = response["name"].stringValue
        self.slug = response["slug"].stringValue
    }
    
    init(name : String, slug: String) {
        self.name = name
        self.slug = slug
    }
}
