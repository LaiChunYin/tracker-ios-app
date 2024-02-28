//
//  UserViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
//    private var authenticationService: AuthenticationService
    private var preferenceService: PreferenceService
//    private var userRepository: UserRepository
    @Published var currentUser: AppUser? = nil
    lazy var rememberMe: Bool? = preferenceService.isRememberLoginStatus
    private var db: Firestore
    
    private var userListener: ListenerRegistration? = nil
    private var notificationsListener: ListenerRegistration? = nil
    

//    init(authenticationService: AuthenticationService, preferenceService: PreferenceService, userRepository: UserRepository) {
//        self.authenticationService = authenticationService
//        self.preferenceService = preferenceService
//        self.userRepository = userRepository
//    }
    
    init(db: Firestore, preferenceService: PreferenceService){
        self.db = db
        self.preferenceService = preferenceService
    }
    
    func login(email: String, password: String, rememberMe: Bool) {
        guard !email.isEmpty && !password.isEmpty else {
            print("empty username or password")
//            return .failure(LoginError.emptyUsernameOrPwd)
            return
        }
//        guard userRepository.getAllUserNames().contains(username) else {
//            print("invalid user")
//            return .failure(LoginError.invalidUser)
//        }
        
//        guard password == currentUser!.password else {
//            print("wrong password")
//            return .failure(LoginError.wrongPwd)
//        }
        
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in

            guard let result = authResult else{
                print(#function, "Error while logging in : \(error)")
                return
            }

            print(#function, "AuthResult : \(result)")

            switch authResult{
                case .none:
                    print(#function, "Unable to sign in")
                case .some(_):
                    print(#function, "Login Successful")
                    
                    if let userAccount = authResult?.user, let identifier = userAccount.email ?? userAccount.phoneNumber {
                        self?.currentUser = AppUser(accountData: userAccount)
//                        self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userAccount.uid).getDocument(as: UserData.self) { result in
                        let userDocRef = self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(identifier)
                        print("adding listener to user data")
//                        let userDocRef = self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userAccount.uid)
                        self!.userListener = userDocRef.addSnapshotListener { docSnapshot, error in
                            
                            guard let document = docSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }

                            guard let userData = try? document.data(as: UserData.self) else {
                                print("Cannot decode document")
                                return
                            }
                            print("updating user data")
                            self!.currentUser!.userData = userData
                            self!.preferenceService.isRememberLoginStatus = rememberMe
                    
                        }
                        
                        self!.notificationsListener = userDocRef.collection(UserDataSubcollections.COLLECTION_NOTIFICATION).addSnapshotListener { querySnapshot, error in
                            print("adding listener to notifications")

                            guard let snapshot = querySnapshot else{
                                print(#function, "Unable to retrieve data from firestore : \(error)")
                                return
                            }
                            
                            snapshot.documentChanges.forEach{ (docChange) in
                                do{
                                    var notification = try docChange.document.data(as: Notification.self)
                                    let notificationId = docChange.document.documentID
                                    
                                    print("getting notification id \(notificationId) ")
                                    
                                    let matchedIndex = self!.currentUser!.notifications.firstIndex(where: {($0.id?.elementsEqual(notificationId))!})
                                    print("match index is \(matchedIndex)")
                                    
                                    switch(docChange.type){
                                        case .added:
                                            print(#function, "Document added : \(notificationId)")
                                            self!.currentUser!.notifications.append(notification)
                                        case .modified:
                                            //replace existing object with updated one
                                            print(#function, "notification modified \(notificationId)")
                                            if (matchedIndex != nil){
                                                self!.currentUser!.notifications[matchedIndex!] = notification
                                            }
                                        case .removed:
                                            //remove object from index in bookList
                                            print(#function, "Document removed : \(notificationId)")
                                            if (matchedIndex != nil){
                                                self!.currentUser!.notifications.remove(at: matchedIndex!)
                                            }
                                    }
                                    
                                }
                                catch let err as NSError {
                                    print(#function, "Unable to convert document into Swift object : \(err)")
                                }
                            }
                        }
                    }
            }

        }
        
    }
    
    func logout() {
        do{
            try Auth.auth().signOut()
            self.currentUser = nil
            
            self.userListener?.remove()
            self.userListener = nil
            
            self.notificationsListener?.remove()
            self.notificationsListener = nil
        }
        catch let err as NSError{
            print(#function, "Unable to sign out the user : \(err)")
        }
//        authenticationService.signOut()
    }
    
    func createAccount(email: String, password: String, confirmPassword: String) {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            print("empty value")
//            return .failure(SignUpError.emptyInputs)
            return
        }
        guard password == confirmPassword else {
            print("password not match")
//            return .failure(SignUpError.confirmPwdNotMatch)
            return
        }

//        guard !userRepository.getAllUserNames().contains(email) else {
//            print("user already exist")
//            return .failure(SignUpError.alreadyExist)
//        }
        guard password.count >= 8 else {
//            return .failure(SignUpError.weakPassword)
            return
        }
        
        print("\(#function), \(email), \(password)")
                
        Auth.auth().createUser(withEmail: email, password: password){ [weak self] authResult, error in
            guard let result = authResult else{
                print(#function, "Error while creating account : \(error)")
                return
            }
            
            print(#function, "AuthResult : \(result)")
            
            switch authResult{
            case .none:
                print(#function, "Unable to create the account")
            case .some(_):
                if let userAccount = authResult?.user, let identifier = userAccount.email ?? userAccount.phoneNumber {
                    let newUserData = UserData()
                    print("new user data is \(newUserData) and \(newUserData.toDictionary())")
//                    self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userAccount.uid).setData(newUserData.toDictionary()!) { error in
                    let userDocRef = self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(identifier)
//                    let userDocRef = self!.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userAccount.uid)
                    userDocRef.setData(newUserData.toDictionary()!) { error in
                        
                        if let error = error {
                            print("error in login \(error)")
                        }
                        print("snapshot of \(userAccount.uid)")
                        
                        let notification = Notification(type: .accountCreated)
                        do {
                            try userDocRef.collection(UserDataSubcollections.COLLECTION_NOTIFICATION).addDocument(from: notification)
//                            print("after adding new account notification \(self?.currentUser?.id)")
                            print("after adding new account notification \(self?.currentUser?.identifier)")
                            self!.currentUser = AppUser(accountData: userAccount, userData: newUserData, notifications: [notification])
                            print("current user is \(self?.currentUser?.identifier)")
//                            print("current user is \(self?.currentUser?.id)")
                        }
                        catch let error as NSError {
                            print("error in creating appuser")
                        }
                    }
                    
//                    self!.db.collection(self!.COLLECTION_USER_NOTIFICATIONS).document(identifier).setData(["Notifications": []]) { error in
//                        
//                        if let error = error {
//                            print("error in login \(error)")
//                        }
//                        print("snapshot of \(userAccount.uid)")
//                    }
                }
            }
            
        }
    }
    
//    func sendNotification(receiverId: String, notificationId: String, extraData: [String: String] = [:]) {
//        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(receiverId).collection(COLLECTION_NOTIFICATIONS).updateData(["notifications.\(notificationId)": extraData])
//    }
    
    func sendNotification(receiverId: String, notification: Notification) {
        do {
            try self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(receiverId).collection(UserDataSubcollections.COLLECTION_NOTIFICATION).addDocument(from: notification)
        }
        catch let error as NSError {
            print("error in sending notification \(error)")
        }
    }
    
    func follow(followerId: String, targetId: String){
//        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(followerId).updateData(["following.\(targetId)": true])
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(followerId).updateData([FieldPath(["following", targetId]): true])
        
//        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(targetId).updateData(["followedBy.\(followerId)": true])
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(targetId).updateData([FieldPath(["followedBy", followerId]): true])
        
        if var following = currentUser?.userData?.following {
            following[targetId] = true
            currentUser?.userData?.following = following
        }
    }
    
    func unfollow(followerId: String, targetId: String){
//        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(followerId).updateData(["following.\(targetId)": FieldValue.delete()])
//        
//        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(targetId).updateData(["followedBy.\(followerId)": FieldValue.delete()])

        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(followerId).updateData([FieldPath(["following", targetId]): FieldValue.delete()])
        
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(targetId).updateData([FieldPath(["followedBy", followerId]): FieldValue.delete()])
        
        if var following = currentUser?.userData?.following {
            following.removeValue(forKey: targetId)
            currentUser?.userData?.following = following
//            currentUser?.userData?.following = following.filter { $0 != targetId }
        }
    }
}


//class UserViewModel: ObservableObject {
//    private var authenticationService: AuthenticationService
//    private var preferenceService: PreferenceService
//    private var userRepository: UserRepository
//    @Published var currentUser: AppUser? = nil
//    lazy var rememberMe: Bool? = preferenceService.isRememberLoginStatus
//    
//
//    init(authenticationService: AuthenticationService, preferenceService: PreferenceService, userRepository: UserRepository) {
//        self.authenticationService = authenticationService
//        self.preferenceService = preferenceService
//        self.userRepository = userRepository
//    }
//    
//    func login(email: String, password: String, rememberMe: Bool) async -> Result<Void, LoginError> {
//        guard !email.isEmpty && !password.isEmpty else {
//            print("empty username or password")
//            return .failure(LoginError.emptyUsernameOrPwd)
//        }
////        guard userRepository.getAllUserNames().contains(username) else {
////            print("invalid user")
////            return .failure(LoginError.invalidUser)
////        }
//        
////        guard password == currentUser!.password else {
////            print("wrong password")
////            return .failure(LoginError.wrongPwd)
////        }
//        
//        do {
//            let signInResult = try await authenticationService.signIn(email: email, password: password)
//            
//            switch signInResult {
//                case .success(let user):
//                    print("before is remember login status")
//                    preferenceService.isRememberLoginStatus = rememberMe
//                    self.currentUser = user
//                    return .success(())
//                case.failure(let error):
//                    print("login failed \(error)")
//            }
//
//        }
//        catch let error as NSError {
//            print("login error \(error)")
//            
//        }
//        print("unknown error in login")
//        return .success(())
//    }
//    
//    func logout() {
//        authenticationService.signOut()
//    }
//    
//    func createAccount(email: String, password: String, confirmPassword: String) async -> Result<Void, SignUpError> {
//        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
//            print("empty value")
//            return .failure(SignUpError.emptyInputs)
//        }
//        guard password == confirmPassword else {
//            print("password not match")
//            return .failure(SignUpError.confirmPwdNotMatch)
//        }
//
////        guard !userRepository.getAllUserNames().contains(email) else {
////            print("user already exist")
////            return .failure(SignUpError.alreadyExist)
////        }
//        guard password.count >= 8 else {
//            return .failure(SignUpError.weakPassword)
//        }
//        
//        print("\(#function), \(email), \(password)")
//        
//        // login directly after signing up
////        currentUser = User(email: email, password: password, rememberMe: false)
//
////        userRepository.addUser(user: currentUser!)
////        authenticationService.signUp(email: email, password: password)
////        return .success(())
//        
//        do {
//            print("signing up")
//            let signUpResult = try await authenticationService.signUp(email: email, password: password)
//            
//            switch signUpResult {
//                case .success(let user):
//                    print("signing up")
//                    self.currentUser = user
//                    return .success(())
//                case.failure(let error):
//                    print("logout failed \(error)")
//            }
//
//        }
//        catch let error as NSError {
//            print("logout error \(error)")
//            
//        }
//        print("unknown error in createAccount")
//        return .success(())
//    }
//}
