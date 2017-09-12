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
import RxDataSources

class Photo: ALSwiftyJSONAble, Equatable, Hashable {
    
    let uuid = UUID.init()
    let id: String
    let imageUrl: String
    
    required init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.imageUrl = jsonData["image_url"].stringValue
    }
    
    init(_ id: String, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }

    func match(_ photo: Photo) -> Bool {
        return id == photo.id && imageUrl == photo.imageUrl
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id && lhs.imageUrl == rhs.imageUrl && lhs.uuid == rhs.uuid
    }
    
    var hashValue: Int {
        return id.hashValue ^ imageUrl.hashValue
    }
    
}
