//
//  protocols.swift
//  tracker_ios_app
//
//  Created by macbook on 1/3/2024.
//

import Foundation

protocol AuthServiceDelegate: AnyObject {
    func onUserInit(user: AppUser)
}

protocol NotificationInitDelegate: AnyObject {
    func onNotificationInit()
}

protocol UserServiceDelegate: AnyObject {
    func onUserInit(user: AppUser)
    func onUserUpdate(userData: UserData)
}

protocol UserDataValidationDelegate: AnyObject {
    func isCurrentUserFollowing(userId: String) -> Bool
    func isCurrentUserFollowedBy(userId: String) -> Bool
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

protocol NotificationRepositoryDelegate: AnyObject {
    func onNotificationChange(type: NotificationChangeType, notificationId: String, notification: Notification)
}

//protocol CastableError {
//    func cast(error: Error) -> LoginError
//    func cast(error: Error) -> SignUpError
//    func cast(error: Error) -> UserError
//    
//    func cast<T: CastableError, U: CastableError>(error: T) -> U
//}
