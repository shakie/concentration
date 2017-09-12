//
//  GameResult.swift
//  Concentration
//
//  Created by Shaun Rowe on 12/09/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import RealmSwift

class GameResult: Object {
    
    dynamic var name = ""
    dynamic var time = TimeInterval(0)
    dynamic var difficulty = 1

}
