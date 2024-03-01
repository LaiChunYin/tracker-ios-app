//
//  UserRepository.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation
import FirebaseFirestore


class UserRepository {
    weak var userRepositoryDelegate: UserRepositoryDelegate?
    private let db: Firestore
    
    init(db : Firestore){
        self.db = db
    }
    
    func listenToUserChanges(userId: String) -> ListenerRegistration {
            let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
            print("adding listener to user data")
            
            let userListener = userDocRef.addSnapshotListener { docSnapshot, error in
                
                guard let document = docSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                guard let userData = try? document.data(as: UserData.self) else {
                    print("Cannot decode document")
                    return
                }
                print("updating user data")
                self.userRepositoryDelegate?.onUserUpdate(userData: userData)
            }
        
            return userListener
    }
    
    func createNewUserDataStorage(userId: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            print("creating new storage for \(userId), \(UserData().toDictionary())")
            
            do {
                let newUserData = UserData()
                let userDocRef = self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId)
                userDocRef.setData(newUserData.toDictionary()!)
                continuation.resume(returning: ())
            }
            catch let error as NSError {
                print("error is \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
    
    func updateUserData(userId: String, newData: [AnyHashable: Any]) {
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).updateData(newData)
    }

    func isUserExist(userId: String) async -> Bool {
        do {
            let document = try await self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).getDocument()
            
            if document.exists {
                print("user exist")
                return true
            } else {
                print("user does not exist")
                return false
            }
        }
        catch let error {
            print("user does not exist: \(error)")
            return false
        }
    }
}
