//
//  Search.swift
//  Concentration
//
//  Created by Shaun Rowe on 16/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import UIKit
import SwiftyJSON
import Moya_SwiftyJSONMapper

final class Search: ALSwiftyJSONAble {

    let photos: [Photo]
    
    required init(jsonData: JSON) {
        var photos = [Photo]()
        for photo in jsonData["photos"].arrayValue {
            photos.append(Photo(jsonData: photo))
        }
        self.photos = photos
    }
    
}
