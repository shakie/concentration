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

class Photo: ALSwiftyJSONAble {
    
    let id: String
    let image_url: String
    
    required init?(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.image_url = jsonData["image_url"].stringValue
    }
    
}
