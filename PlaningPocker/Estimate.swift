//
//  Estimate.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 02.09.2021.
//

import Foundation
import RealmSwift

class Estimate: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userName: String = ""
    @Persisted var estimate: String = ""
    
    convenience init(userName: String, estimate:String) {
        self.init()
        self.userName = userName
        self.estimate = estimate
    }
}
