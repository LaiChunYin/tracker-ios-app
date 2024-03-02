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
    
    func follow(followerId: String, targetId: String) async throws {
        let followerUserData: UserData = try await userRepository.getUserDataById(userId: followerId)
        
        let connectAt: Date = Date.now
        
        var followerInfoDict: [String: Any] = followerUserData.getUserSummaryDict()
        var targetInfoDict: [String: Any] = currentUser!.userData!.getUserSummaryDict()
        
        followerInfoDict["connectionTime"] = connectAt
        targetInfoDict["connectionTime"] = connectAt
        
        // use FieldPath to make Firebase to correctly treat a dot as part of the email instead of the next position in the path
        userRepository.updateUserData(userId: followerId, newData: [FieldPath(["following", targetId]): targetInfoDict])
      
        userRepository.updateUserData(userId: targetId, newData: [FieldPath(["followedBy", followerId]): followerInfoDict])
        
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
    
    // when a user updates his profile, the latest profile will be stored into the following field of all of his followers. Here, we don't choose the approach of getting the user profile at the time of loading the following list, because it will take for database operations
    func updateProfile(userId: String, nickName: String, profilePic: String) async throws {
        let following = self.currentUser?.userData?.following.keys.map {$0} ?? []
        let followers = self.currentUser?.userData?.followedBy.keys.map {$0} ?? []
        
        // update self profile pic
        var userIdAndDataTuples: [(String, [AnyHashable: Any])] = [(userId, ["nickName": nickName, "profilePic": profilePic])]
        
        // notify users that the current user follows or is followed by the current user that the profile is changing
        for follower in followers {
            print("in batch follower: \(follower)")
        
            userIdAndDataTuples.append((follower, [FieldPath(["following", userId, "nickName"]): nickName, FieldPath(["following", userId, "profilePic"]): profilePic]))
        }
        
        for follow in following {
            print("in batch follow: \(follow)")
        
            userIdAndDataTuples.append((follow, [FieldPath(["followedBy", userId, "nickName"]): nickName, FieldPath(["followedBy", userId, "profilePic"]): profilePic]))
        }
        
        do {
            try await userRepository.updateUserDataInBatch(userIdAndDataTuples: userIdAndDataTuples)
        }
        catch let error {
            print("cannot update in batch: \(error)")
            throw error
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
