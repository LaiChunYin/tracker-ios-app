//
//  NotificationViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation
import FirebaseFirestore

class NotificationViewModel: ObservableObject {
//    @Published var notifications: [Notification] = []
    private var userViewModel: UserViewModel
    private var db: Firestore
    
    
    init(db: Firestore,userViewModel: UserViewModel) {
        self.db = db
        self.userViewModel = userViewModel
//        self.getNotificationByUserId(userId: userViewModel.currentUser!.identifier)
    }
    
    func requestFollow(target: String, by: String) {
        guard target != by else {
            print("cannot follow yourself")
            return
        }
        
        guard !target.isEmpty else {
            print("target cannot be empty")
            return
        }
        
        do{
            let targetNotification = Notification(type: .invitationReceived, extraData: ["follower": by])
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: targetNotification).documentID
            
//            userViewModel.sendNotification(receiverId: target, notificationId: notificationId)
            userViewModel.sendNotification(receiverId: target, notification: targetNotification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
        
        do{
            let followerNotification = Notification(type: .invitationSent, extraData: ["target": target])
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: followerNotification).documentID
//            
//            userViewModel.sendNotification(receiverId: by, notificationId: notificationId)
            
            userViewModel.sendNotification(receiverId: by, notification: followerNotification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
//    func getNotificationByUserId(userId: String) {
//        self.db.collection(COLLECTION_USER_NOTIFICATIONS).document(userId)
//            .collection(COLLECTION_NOTIFICATIONS)
//            .addSnapshotListener({ (querySnapshot, error) in
//                
//                guard let snapshot = querySnapshot else{
//                    print(#function, "Unable to retrieve data from firestore : \(error)")
//                    return
//                }
//                
//                snapshot.documentChanges.forEach{ (docChange) in
//                    do{
//                        var notificationIdWithData = try docChange.document.data()
//                        print("notificationidwithdata is \(notificationIdWithData)")
//                        let userId = docChange.document.documentID
//                        
//                        for (notificationId, extraData) in notificationIdWithData {
//                            print("getting notification id \(notificationId) ")
//                            var notification: Notification = self.db.collection(COLLECTION_NOTIFICATIONS).document(notificationId).data(as: Notification.self)
//                            notification.extraData = extraData as! [String: String]
//                            
//                            let matchedIndex = self.notifications.firstIndex(where: {($0.id?.elementsEqual(notificationId))!})
//                            print("match index is \(matchedIndex)")
//                            
//                            switch(docChange.type){
//                                case .added:
//                                    print(#function, "Document added : \(notificationId)")
//                                    self.notifications.append(notification)
//                                case .modified:
//                                    //replace existing object with updated one
//                                    print(#function, "notification modified \(notificationId)")
//                                    if (matchedIndex != nil){
//                                        self.notifications[matchedIndex!] = notification
//                                    }
//                                case .removed:
//                                    //remove object from index in bookList
//                                    print(#function, "Document removed : \(notificationId)")
//                                    if (matchedIndex != nil){
//                                        self.notifications.remove(at: matchedIndex!)
//                                    }
//                            }
//                        }
//                        
//                        
//                    }
//                    catch let err as NSError {
//                        print(#function, "Unable to convert document into Swift object : \(err)")
//                    }
//                    
//                }
//            })
//    }
//    
    func notificationRead(userId: String, notificationId: String) {
        self.updateNotification(userId: userId, notificationId: notificationId, newData: ["read": true])
    }
    
    func updateNotification(userId: String, notificationId: String, newData: [String: Any]) {
        self.db.collection(FireBaseCollections.COLLECTION_USER_DATA).document(userId).collection(UserDataSubcollections.COLLECTION_NOTIFICATION).document(notificationId).updateData(newData)
    }
    
    func acceptFollowRequest(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .invitationAccepted, extraData: ["target": by])
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: notification).documentID
//            
//            userViewModel.sendNotification(receiverId: receiverId, notificationId: notificationId)
            
            userViewModel.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func rejectFollowRequest(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .invitationRejected, extraData: ["target": by])
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: notification).documentID
//            
//            userViewModel.sendNotification(receiverId: receiverId, notificationId: notificationId)
            
            userViewModel.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func removeFollower(receiverId: String, by: String) {
        do{
            let notification = Notification(type: .subscriberRemoved, extraData: ["target": by])
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: notification).documentID
//            
//            userViewModel.sendNotification(receiverId: receiverId, notificationId: notificationId)
            
            userViewModel.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
    
    func actionDone(userId: String, notificationId: String) {
        self.updateNotification(userId: userId, notificationId: notificationId, newData: ["actionTaken": true])
    }
    
    func testing(receiverId: String) {
        do{
            let notification = Notification(type: .testing)
//            let notificationId = try self.db.collection(COLLECTION_NOTIFICATIONS).addDocument(from: notification).documentID
//            
//            userViewModel.sendNotification(receiverId: receiverId, notificationId: notificationId)
            
            userViewModel.sendNotification(receiverId: receiverId, notification: notification)
        }
        catch let err as NSError{
            print(#function, "Unable to add document to firestore : \(err)")
        }
    }
}
