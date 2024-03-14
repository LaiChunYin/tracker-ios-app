//
//  Constants.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore

enum NotificationTypes: Codable {
    case testing  // remove later
    
    case accountCreated
    case invitationReceived
    case invitationSent
    case invitationAccepted
    case invitationRejected
    case subscriberRemoved
    case enteredRegion
    case exitedRegion
}

enum RootViews {
    case main
    case notifications
}

enum MainViewTabs {
    case map
    case following
    case followedBy
}

struct UserDefaultsKeys {
    static let REMEMBER_ME = "REMEMBER_ME"
    static let GEOFENCE_RADIUS = "GEOFENCE_RADIUS"
    static let MAX_TIME_DIFF_BTW_2_PTS = "MAX_TIME_DIFF_BTW_2_PTS"
    static let LOCATION_UPLOAD_TIME_INTERVAL = "LOCATION_UPLOAD_TIME_INTERVAL"
}

struct FireBaseCollections {
    static let COLLECTION_USER_DATA = "User_Data"
}

struct UserDataSubcollections {
    static let COLLECTION_NOTIFICATION = "Notifications"
    static let COLLECTION_WAYPOINT = "WayPoints"
}

struct UserDataFields {
    static let CONNECTION_TIME = "connectionTime"
    static let FOLLOWING = "following"
    static let FOLLOWED_BY = "followedBy"
    static let NICKNAME = "nickName"
    static let PROFILE = "profilePic"
}

struct NotificationFields {
    static let READ = "read"
    static let ACTION_TAKEN = "actionTaken"
}

enum DataChangeType {
    case added
    case updated
    case removed
}

