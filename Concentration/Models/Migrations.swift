//
//  Migrations.swift
//  Concentration
//
//  Created by Shaun Rowe on 16/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import RealmSwift

class Migrations {
    
    static func migrate() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    //Nothing to do until we change the schema
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
                                               ofItemAtPath: realm.configuration.fileURL!.deletingLastPathComponent().path)
    }
    
}
