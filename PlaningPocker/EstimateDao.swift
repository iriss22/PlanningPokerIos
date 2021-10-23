//
//  EstimateDao.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 02.09.2021.
//

import Foundation
import RealmSwift

class EstimateDao {
    
    func estimate(_ realm: Realm, _ userName: String, _ estimate: String) {
        try! realm.write{
            let est = Estimate(userName: userName, estimate: estimate)
            realm.add(est)
        }
    }
    
    func deleteEstimates(_ realm: Realm) {
        try! realm.write {
            let estimates = realm.objects(Estimate.self)
            realm.delete(estimates)
        }
    }
    
    func deleteEstimate(_ realm: Realm, _ userName: String) {
        try! realm.write {
            let estimates = realm.objects(Estimate.self).filter("userName=%@", userName)
            realm.delete(estimates)
        }
    }
}
