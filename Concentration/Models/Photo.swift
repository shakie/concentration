//
//  Photo.swift
//  Concentration
//
//  Created by Shaun Rowe on 11/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import Moya_SwiftyJSONMapper
import SwiftyJSON

class Photo: ALSwiftyJSONAble, Equatable, Hashable {
    
    let id: String
    let image_url: String
    
    required init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.image_url = jsonData["image_url"].stringValue
    }
    
    init(_ id: String, image_url: String) {
        self.id = id
        self.image_url = image_url
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id && lhs.image_url == rhs.image_url
    }
    
    var hashValue: Int {
        return id.hashValue ^ image_url.hashValue
    }
    
}
