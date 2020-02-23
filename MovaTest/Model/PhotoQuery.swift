//
//  PhotoQuery.swift
//  MovaTest
//
//  Created by Danil Shchegol on 22.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import RealmSwift

final class PhotoQuery: Object {
        
    @objc dynamic var id: String?
    @objc dynamic var url: String?
    @objc dynamic var query: String?
    @objc dynamic var date: Date?
        
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String, url: String, query: String) {
        self.init()
        self.id = id
        self.url = url
        self.query = query
        self.date = Date()
    }
}
