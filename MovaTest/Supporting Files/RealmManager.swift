//
//  RealmManager.swift
//  MovaTest
//
//  Created by Danil Shchegol on 22.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import RealmSwift

final class RealmManager {
    
    private init() {}
    
    static let `default` = try! Realm(configuration: RealmManager.defaultConfiguration())
    
    static func add<T: Object>(objects: [T]) {
        do {
            try? RealmManager.default.safeWrite {
                RealmManager.default.add(objects, update: .all)
            }
        }
    }
    
    static func defaultConfiguration() -> Realm.Configuration {
        let config = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        return config
    }
}

extension Realm {
    func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
