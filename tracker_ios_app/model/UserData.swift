//
//  UserData.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth

struct Address: Codable {
    let street: String
    let city: String
    let province: String
    let country: String
}

struct Waypoint: Codable {
    let longitude: Double
    let latittude: Double
    let address: Address
    let time: Date
}


struct UserData: Codable {
//    @DocumentID var id: String?
    var isConnected: Bool = false
//    var currentLocation
    var path: [Waypoint] = []
//    var following: [String] = []
//    var followedBy: [String] = []
//    var notifications: [Notification] = []
    var following: [String: Bool] = [:]
    var followedBy: [String: Bool] = [:]
//    var notifications: [String: [String: String]] = [:]
}

struct AppUser {
    let accountData: User
    var userData: UserData? = nil
    var notifications: [Notification] = []
//    var id: String {
//        get {
//            return self.accountData.uid
//        }
//    }
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
    
//    init(accountData: User, userData: UserData, notifications: [Notification]) {
//        self.accountData = accountData
//        self.userData = userData
//        self.notifications = notifications
//    }
}
