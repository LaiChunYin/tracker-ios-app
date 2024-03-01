//
//  Constants.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore

enum LoginError: Error, Identifiable {
    var id: Self {self}
    
    case emptyUsernameOrPwd
    case invalidUser
    case wrongPwd
//    case FireAuthError(Error)
    case unknown
}

enum SignUpError: Error,Identifiable {
    var id: Self {self}
    
    case alreadyExist
    case weakPassword
    case confirmPwdNotMatch
    case emptyInputs
    case unknown
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


protocol AuthServiceDelegate: AnyObject {
    func onUserInit(user: AppUser)
}

protocol NotificationInitDelegate: AnyObject {
    func onNotificationInit()
}

protocol UserServiceDelegate: AnyObject {
    func onUserUpdate(userData: UserData)
}

protocol NotificationServiceDelegate: AnyObject {
//    func updateNotificationOnChange(notificationId: String, notification: Notification)
    func onNotificationAdded(notificationId: String, notification: Notification)
    func onNotificationUpdated(notificationId: String, notification: Notification)
    func onNotificationRemoved(notificationId: String, notification: Notification)
}

protocol UserRepositoryDelegate: AnyObject {
    func onUserUpdate(userData: UserData)
}

enum NotificationChangeType {
    case added
    case updated
    case removed
}

protocol NotificationRepositoryDelegate: AnyObject {
    func onNotificationChange(type: NotificationChangeType, notificationId: String, notification: Notification)
}
