//
//  UserService.swift
//  tracker_ios_app
//
//  Created by macbook on 29/2/2024.
//

import Foundation
import FirebaseFirestore

class UserService: UserRepositoryDelegate {
    weak var userServiceDelegate: UserServiceDelegate?
    private var userRepository: UserRepository
    private var notificationService: NotificationService
    
    init(userRepository: UserRepository, notificationService: NotificationService) {
        self.userRepository = userRepository
        self.notificationService = notificationService
        
        self.userRepository.userRepositoryDelegate = self
    }

    func onUserUpdate(userData: UserData) {
        print("in auth service update user on change")
        userServiceDelegate?.onUserUpdate(userData: userData)
    }
    
    func follow(followerId: String, targetId: String) {
        // use FieldPath to make Firebase to correctly treat a dot as part of the email instead of the next position in the path
        userRepository.updateUserData(userId: followerId, newData: [FieldPath(["following", targetId]): true])
      
        userRepository.updateUserData(userId: targetId, newData: [FieldPath(["followedBy", followerId]): true])
        
        notificationService.sendAcceptedNotification(receiverId: followerId, by: targetId)
    }
    
    func unfollow(followerId: String, targetId: String, isRemovingFollower: Bool) {
        // use FieldPath to make Firebase to correctly treat a dot as part of the email instead of the next position in the path
        userRepository.updateUserData(userId: followerId, newData: [FieldPath(["following", targetId]): FieldValue.delete()])
      
        userRepository.updateUserData(userId: targetId, newData: [FieldPath(["followedBy", followerId]): FieldValue.delete()])
        
        if isRemovingFollower {
            notificationService.sendRemovedNotification(receiverId: followerId, by: targetId)
        }
    }
}
