//
//  UserViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject, UserServiceDelegate, AuthServiceDelegate {
    private var authenticationService: AuthenticationService
    private var preferenceService: PreferenceService
    private var userService: UserService
    @Published var currentUser: AppUser? = nil
    lazy var rememberMe: Bool? = preferenceService.isRememberLoginStatus
    
    private var userListener: ListenerRegistration? = nil
    private var notificationsListener: ListenerRegistration? = nil
    
    init(authenticationService: AuthenticationService, preferenceService: PreferenceService, userService: UserService){
        self.authenticationService = authenticationService
        self.preferenceService = preferenceService
        self.userService = userService
        
        self.authenticationService.authServiceDelegate = self
        self.userService.userServiceDelegate = self
    }
    
    func onUserInit(user: AppUser) {
        DispatchQueue.main.async {
            print("initializing user")
            self.currentUser = user
        }
    }
    
    func onUserUpdate(userData: UserData) {
        DispatchQueue.main.async {
            print("in user view model updating user data on change")
            self.objectWillChange.send()
            self.currentUser?.userData = userData
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool) async throws {
        guard !email.isEmpty && !password.isEmpty else {
            print("empty username or password")
            throw LoginError.emptyUsernameOrPwd
        }
        
        do {
            try await authenticationService.signIn(email: email, password: password)
            self.preferenceService.isRememberLoginStatus = rememberMe
        }
        catch let error as NSError {
            print("error in login \(error)")
        }
    }
    
    func logout() {
        do{
            try authenticationService.signOut()
            self.currentUser = nil
        }
        catch let err as NSError{
            print(#function, "Unable to sign out the user : \(err)")
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) async throws {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("empty value")
            throw SignUpError.emptyInputs
        }
        guard password == confirmPassword else {
            print("password not match")
            throw SignUpError.confirmPwdNotMatch
        }

        guard password.count >= 8 else {
            throw SignUpError.weakPassword
        }
//        guard !userRepository.getAllUserNames().contains(email) else {
//            print("user already exist")
//            return .failure(SignUpError.alreadyExist)
//        }
        
        print("\(#function), \(email), \(password)")
              
        do {
            try await authenticationService.signUp(email: email, password: password)
        }
        catch let error as NSError {
            print("error in sign up \(error)")
        }
    }
    
    
    
    func follow(followerId: String, targetId: String) {
        userService.follow(followerId: followerId, targetId: targetId)
        
        if var following = currentUser?.userData?.following {
            following[targetId] = true
            currentUser?.userData?.following = following
        }
    }
    
    func unfollow(followerId: String, targetId: String, isRemoveingFollower: Bool) {
        userService.unfollow(followerId: followerId, targetId: targetId, isRemovingFollower: isRemoveingFollower)
        
        if var following = currentUser?.userData?.following {
            following.removeValue(forKey: targetId)
            currentUser?.userData?.following = following
        }
    }
}

