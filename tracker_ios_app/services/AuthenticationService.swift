//
//  AuthenticationService.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AuthenticationService {
    weak var authServiceDelegate: AuthServiceDelegate?
    weak var notificationInitDelegate: NotificationInitDelegate?
    private var preferenceService: PreferenceService
    private var notificationService: NotificationService
    private var userRepository: UserRepository
    private var notificationRepository: NotificationRepository
    private var userListener: ListenerRegistration? = nil
    private var notificationsListener: ListenerRegistration? = nil
    private var currentUser: AppUser? = nil
    
    init(preferenceService: PreferenceService, notificationService: NotificationService, userRepository: UserRepository, notificationRepository: NotificationRepository) {
        self.preferenceService = preferenceService
        self.notificationService = notificationService
        self.userRepository = userRepository
        self.notificationRepository = notificationRepository
    }
    
    func signUp(email : String, password : String) async throws {
        do {
            let userAccount = try await self.createAccount(email: email, password: password)
            
            if let identifier = userAccount.email ?? userAccount.phoneNumber {
                try await userRepository.createNewUserDataStorage(userId: identifier)
                notificationService.sendNewAccountNotification(receiverId: identifier)
                self.currentUser = AppUser(accountData: userAccount, userData: UserData())
                print("current user is \(identifier)")
//                authServiceDelegate?.onUserInit(user: self.currentUser!)
//                notificationInitDelegate?.onNotificationInit()
                
                self.initializeData(user: self.currentUser!)
            }
        }
        catch let error as NSError {
            print("error in creating appuser")
        }
    }
    
    func createAccount(email : String, password : String) async throws -> User {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error as? NSError {
                    print("sign in error is \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                switch authResult{
                    case .none:
                        print(#function, "Unable to create the account")
                        continuation.resume(throwing: SignUpError.unknown)
                    case .some(_):
                        if let userAccount = authResult?.user {
                            continuation.resume(returning: authResult!.user)
                        }
                }
                
            }
        }
    }
    
    func signIn(email : String, password : String) async throws {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error as? NSError {
                    print("sign in error is \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                switch authResult{
                    case .none:
                        print(#function, "Unable to sign in")
                        continuation.resume(throwing: LoginError.unknown)
                    case .some(_):
                        print(#function, "Login Successful")
                        
                        if let userAccount = authResult?.user {
                            self!.currentUser = AppUser(accountData: userAccount)
                            
                            self!.initializeData(user: self!.currentUser!)
//                            self!.authServiceDelegate?.onUserInit(user: self!.currentUser!)
//                            
//                            self!.userListener = self!.userRepository.listenToUserChanges(userId: self!.currentUser!.identifier)
//                            
//                            self!.notificationsListener = self!.notificationRepository.listenToNotificationChanges(userId: self!.currentUser!.identifier)
                        }
                        continuation.resume(returning: ())
                }
            }
        }
    }
    
    func signOut() throws {
        do{
            try Auth.auth().signOut()
            self.resetListeners()
        }
        catch let err as NSError{
            print(#function, "Unable to sign out the user : \(err)")
            throw err
        }
    }
    
    func initializeData(user: AppUser) {
        print("initializing data")
        self.resetListeners()
        
        self.authServiceDelegate?.onUserInit(user: user)
        self.notificationInitDelegate?.onNotificationInit()
        
        self.userListener = self.userRepository.listenToUserChanges(userId: user.identifier)
        
        self.notificationsListener = self.notificationRepository.listenToNotificationChanges(userId: user.identifier)
    }
    
    func resetListeners() {
        print("resetting listeners")
        if self.userListener != nil {
            self.userListener?.remove()
            self.userListener = nil
        }
        
        if self.notificationsListener != nil {
            self.notificationsListener?.remove()
            self.notificationsListener = nil
        }
    }
}
