//
//  UserService.swift
//  tracker_ios_app
//
//  Created by macbook on 29/2/2024.
//

import Foundation
import FirebaseFirestore

class UserService: UserRepositoryDelegate, AuthServiceDelegate, UserDataValidationDelegate {
    weak var userServiceDelegate: UserServiceDelegate?
    private var authenticationService: AuthenticationService
    private var userRepository: UserRepository
    private var notificationService: NotificationService
    private var currentUser: AppUser? = nil
    
    init(userRepository: UserRepository, authenticationService: AuthenticationService, notificationService: NotificationService) {
        self.userRepository = userRepository
        self.authenticationService = authenticationService
        self.notificationService = notificationService
        
        self.userRepository.userRepositoryDelegate = self
        self.authenticationService.authServiceDelegate = self
    }

    
    func onUserInit(user: AppUser) {
        print("in auth service update user on change")
        self.currentUser = user
        userServiceDelegate?.onUserInit(user: user)
    }
    
    func onUserUpdate(userData: UserData) {
        print("in auth service update user on change")
        self.currentUser?.userData = userData
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
    
    func isCurrentUserFollowing(userId: String) -> Bool {
        if self.currentUser!.userData!.following.keys.contains(userId) {
            print("already following")
            return true
        }
        print("not already following")
        return false
    }
    
    func isCurrentUserFollowedBy(userId: String) -> Bool {
        if self.currentUser!.userData!.followedBy.keys.contains(userId) {
            print("already followed by")
            return true
        }
        print("not already followed by")
        return false
    }
    
    func checkUserExistence(userId: String) async -> Bool {
        return await userRepository.isUserExist(userId: userId)
    }
}
