//
//  Room.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 02.09.2021.
//

import Foundation
import RealmSwift

class Room: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
