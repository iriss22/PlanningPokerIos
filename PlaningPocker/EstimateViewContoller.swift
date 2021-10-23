//
//  EstimateViewContoller.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 10.08.2021.
//

import Foundation

import UIKit
import RealmSwift

class EstimateViewController: UIViewController {
    @IBOutlet  var estimatesTV: UITableView!
    
    let user = app.currentUser!
    var partitionValue = "room="
    var configuration: Realm.Configuration?
    var realm: Realm?
    
    var userName: String = ""
    var roomId: String = ""
    var estimate: String?
    
    var estimates: Results<Estimate>?
    var notificationToken: NotificationToken?
    
    func initArg(userName: String, roomId: String) {
        self.userName = userName
        self.roomId = roomId
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatesTV.delegate =  self
        estimatesTV.dataSource = self
        
        partitionValue = "room=" + roomId
        configuration = user.configuration(partitionValue: partitionValue)
        realm = try! Realm(configuration: configuration!)
        
        initEstimateList()
    }
    
    func initEstimateList() {
        estimates = realm!.objects(Estimate.self).sorted(byKeyPath: "_id")
        notificationToken = estimates!.observe { [weak self] (changes) in
            guard let tableView = self?.estimatesTV else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                })
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @IBAction func estimateAction(_ sender: UIButton) {
        if (estimate == nil) {
            self.estimate(userName: userName, estimate: sender.titleLabel!.text!)
        } else {
            NotificationFactory().showErrorNotification(vc: self, message: "Вы уже проголосовали!")
        }
    }
    
    func estimate(userName: String, estimate: String) {
        Realm.asyncOpen(configuration: configuration!) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error.localizedDescription)")
                NotificationFactory().showErrorNotification(vc: self, message: "Попробуйте позже.")
            case .success(let realm):
                EstimateDao().estimate(realm, userName, estimate)
                self.estimate = estimate
            }
        }
    }
    
    @IBAction func deleteEstimatesAction(_ sender: UIButton) {
        self.deleteEstimates()
    }
    
    func deleteEstimates() {
        Realm.asyncOpen(configuration: configuration!) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error.localizedDescription)")
                NotificationFactory().showErrorNotification(vc: self, message: "Попробуйте позже.")
            case .success(let realm):
                EstimateDao().deleteEstimates(realm)
                self.estimate = nil
            }
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        print("back")
    }
}

extension EstimateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tupped me!")
    }
}

extension EstimateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.estimates!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(self.estimates![indexPath.row].userName) \(String(repeating: " ", count: 15 - self.estimates![indexPath.row].userName.count))\(self.estimates![indexPath.row].estimate)"
        
        return cell
    }
}
