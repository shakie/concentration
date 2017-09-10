//
//  Game.swift
//  Concentration
//
//  Created by Shaun Rowe on 16/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import RealmSwift

class Game: Object {
 
    dynamic var time: Date = Date()
    let players = List<Player>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
