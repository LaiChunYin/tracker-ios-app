//
//  Constants.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation

enum LoginError: Error, Identifiable {
    var id: Self {self}
    
    case emptyUsernameOrPwd
    case invalidUser
    case wrongPwd
}

enum SignUpError: Error,Identifiable {
    var id: Self {self}
    
    case alreadyExist
    case weakPassword
    case confirmPwdNotMatch
    case emptyInputs
}

enum NotificationTypes: Codable {
    case testing  // remove later
    
    case accountCreated
    case invitationReceived
    case invitationSent
    case invitationAccepted
    case invitationRejected
    case subscriberRemoved
}

enum RootViews {
    case main
    case notifications
}

struct UserDefaultsKeys {
    static let REMEMBER_ME = "REMEMBER_ME"
}

struct FireBaseCollections {
    static let COLLECTION_USER_DATA = "User_Data"
}

struct UserDataSubcollections {
    static let COLLECTION_NOTIFICATION = "Notifications"
}


