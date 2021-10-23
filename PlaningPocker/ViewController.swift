//
//  ViewController.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 19.07.2021.
//

import UIKit
import RealmSwift
import Realm.RLMUser

class ViewController: UIViewController {
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    
    var currentUser = app.currentUser
    let partitionRoomValue = "space=default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorize()
    }
    
    func authorize() {
        if (app.currentUser == nil) {
            print("not user auth")
            app.login(credentials: Credentials.anonymous) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("Login failed: \(error)")
                    case .success(let user):
                        print("Login as \(user) succeeded!")
                        self.currentUser = app.currentUser
                    }
                }
            }
        }
    }
    
    func checkAuthorizeAndRetry() -> Bool {
        if currentUser == nil {
            authorize()
        }
        return currentUser != nil
    }
    
    func isRoomAndUserNameExist() -> Bool {
        let roomName = self.roomNameField.text ?? ""
        if roomName.isEmpty {
            NotificationFactory().showErrorNotification(vc: self, message: "Введите название комнаты")
        }
        let userName = self.userNameField.text ?? ""
        if userName.isEmpty {
            NotificationFactory().showErrorNotification(vc: self, message: "Введите имя")
        }
        return !roomName.isEmpty && !userName.isEmpty
    }
    
    @IBAction func existRoomAction(_ sender: UIButton) {
        if !checkAuthorizeAndRetry() {
            NotificationFactory().showErrorNotification(vc: self, message: "Не получилось соединиться с сервером. Попробуйте позже.")
            return
        }
        if isRoomAndUserNameExist() {
            openExistRoom(roomName: self.roomNameField.text!, userName: self.userNameField.text!, user: currentUser!)
        }
    }
    
    @IBAction func createRoomAction(_ sender: UIButton) {
        if !checkAuthorizeAndRetry() {
            NotificationFactory().showErrorNotification(vc: self, message: "Не получилось соединиться с сервером. Попробуйте позже.")
            return
        
        }
        if isRoomAndUserNameExist() {
            createNewRoomAndOpen(roomName: self.roomNameField.text!, userName: self.userNameField.text!, user: currentUser!)
        }
    }
    
    func openVoteScreen(room: Room, userName: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "VoteScreen") as! EstimateViewController
        vc.initArg(userName: userName, roomId: room._id.stringValue)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openExistRoom(roomName: String, userName: String, user: RLMUser) {
        let configuration = user.configuration(partitionValue: partitionRoomValue)
        Realm.asyncOpen(configuration: configuration) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error.localizedDescription)")
                NotificationFactory().showErrorNotification(vc: self, message: "Попробуйте позже.")
            case .success(let realm):
                let room = RoomDao().getRoom(realm, roomName)
                if (room != nil) {
                    self.deleteEstimates(room!._id.stringValue, user: user, userName: userName)
                    self.openVoteScreen(room: room!, userName: userName)
                } else {
                    NotificationFactory().showErrorNotification(vc: self, message: "Такой комнаты не существует!")
                }
            }
        }
    }
    
    func createNewRoomAndOpen(roomName: String, userName: String, user: RLMUser) {
        let configuration = user.configuration(partitionValue: partitionRoomValue)
        Realm.asyncOpen(configuration: configuration) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error.localizedDescription)")
                NotificationFactory().showErrorNotification(vc: self, message: "Попробуйте позже.")
            case .success(let realm):
                if (RoomDao().getRoom(realm, roomName) != nil) {
                    NotificationFactory().showErrorNotification(vc: self, message: "Такая комната уже существует. Введите другое имя.")
                } else {
                    let room = RoomDao().createRoom(realm, roomName)
                    self.openVoteScreen(room: room, userName: userName)
                }
            }
        }
    }
    
    func deleteEstimates(_ roomId: String, user: RLMUser, userName: String) {
        let partitionEstimateValue = "room=" + roomId
        let configuration = user.configuration(partitionValue: partitionEstimateValue)
        Realm.asyncOpen(configuration: configuration) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error.localizedDescription)")
                NotificationFactory().showErrorNotification(vc: self, message: "Попробуйте позже.")
            case .success(let realm):
                EstimateDao().deleteEstimate(realm, userName)
            }
        }
    }
}
