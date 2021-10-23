//
//  RoomDao.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 02.09.2021.
//

import Foundation
import RealmSwift

class RoomDao {
    
    func getRooms(_ realm: Realm) -> Results<Room> {
        let rooms = realm.objects(Room.self)
        print("count: " + String(rooms.elements.count))
        print("name 1: " + String(rooms.elements[0].name))
        return rooms
    }
    
    func getRoom(_ realm: Realm, _ name: String)-> Room? {
        return getRooms(realm).filter("name=%@", name).first
    }
    
    func createRoom(_ realm: Realm, _ name: String) -> Room {
        let room = Room(name: name)
        try! realm.write{realm.add(room)}
        print("room created")
        return room
    }
}
