//
//  UserData.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth
import CoreLocation


struct UserData: Codable {
//    @DocumentID var id: String?
    var isConnected: Bool = false
    var nickName: String = ""
    var profilePic: String = ""
//    var geofencingRadius: Int = 0
    var following: [String: UserItemSummary] = [:]
    var followedBy: [String: UserItemSummary] = [:]
    
    init(nickName: String = "") {
        print("initing nick name")
        self.nickName = nickName
    }
    
    func getUserSummaryDict() -> [String: Any] {
        return ["nickName": nickName, "profilePic": profilePic]
    }
}

struct UserItemSummary: Codable {
    var nickName: String
    var profilePic: String
    var connectionTime: Date
}

struct AppUser {
    let accountData: User
    var userData: UserData? = nil
    var notifications: [Notification] = []
    var locations: [Waypoint] = []
    
    var identifier: String {
        get {
            return self.accountData.email ?? self.accountData.phoneNumber ?? self.accountData.uid
        }
    }
    
    init(accountData: User) {
        self.accountData = accountData
    }
    
    init(accountData: User, userData: UserData) {
        self.accountData = accountData
        self.userData = userData
    }
}
