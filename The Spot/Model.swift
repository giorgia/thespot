//
//  Model.swift
//  The Spot
//
//  Created by Giorgia Marenda on 9/21/17.
//  Copyright © 2017 Giorgia Marenda. All rights reserved.
//

import Foundation

class ContactHistory: NSObject, NSCoding {
    var contactFullname: String
    var receivedSpots: [String]
    var sentSpots: [String]
    
    init(contactFullname: String, receivedSpots: [String], sentSpots: [String]) {
        self.contactFullname = contactFullname
        self.receivedSpots = receivedSpots
        self.sentSpots = sentSpots
    }
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        guard let contactFullname = decoder.decodeObject(forKey: "contactFullname") as? String,
            let receivedSpots = decoder.decodeObject(forKey: "receivedSpots") as? [String],
            let sentSpots = decoder.decodeObject(forKey: "sentSpots") as? [String]
            else { return nil }
        
        self.init(contactFullname: contactFullname, receivedSpots: receivedSpots, sentSpots: sentSpots)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.contactFullname, forKey: "contactFullname")
        coder.encode(self.receivedSpots, forKey: "receivedSpots")
        coder.encode(self.sentSpots, forKey: "sentSpots")
    }
}

enum StoreKey: String {
    case contactHistoryKey = "contactHistory"
}

class Store {
    
    static func addSentMessage(to contactFullname: String, placeID: String) {
        var contactsHistories = Store.fetch(key: .contactHistoryKey) as? [ContactHistory]
        if contactsHistories == nil {
            contactsHistories = [ContactHistory]()
        }
        if let history = contactsHistories?.filter({$0.contactFullname == contactFullname}).first {
            history.sentSpots.append(placeID)
        } else {
            let newHistory = ContactHistory(contactFullname: contactFullname, receivedSpots: [], sentSpots: [placeID])
            contactsHistories?.append(newHistory)
        }
        Store.save(object: contactsHistories, with: .contactHistoryKey)
    }
    
    static func addReceivedMessage(from contactFullname: String, placeID: String) {
        var contactsHistories = Store.fetch(key: .contactHistoryKey) as? [ContactHistory]
        if contactsHistories == nil {
            contactsHistories = [ContactHistory]()
        }
        if let history = contactsHistories?.filter({$0.contactFullname == contactFullname}).first {
            history.receivedSpots.append(placeID)
        } else {
            let newHistory = ContactHistory(contactFullname: contactFullname, receivedSpots: [placeID], sentSpots: [])
            contactsHistories?.append(newHistory)
        }
        Store.save(object: contactsHistories, with: .contactHistoryKey)
    }
    
    static func removeHistory(for contactFullname: String) {
        guard var contactsHistories = Store.fetch(key: .contactHistoryKey) as? [ContactHistory] else { return }
        if let index = contactsHistories.index(where: { $0.contactFullname == contactFullname }) {
            contactsHistories.remove(at: index)
            Store.save(object: contactsHistories, with: .contactHistoryKey)
        }
    }
    
    static func save(object: [NSCoding]?, with key: StoreKey) {
        guard let object = object else { return }
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(data, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func fetch(key: StoreKey) -> Any? {
        if let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data {
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            return object
        }
        return nil
    }
}
