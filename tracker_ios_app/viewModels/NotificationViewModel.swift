//
//  NotificationViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation
import FirebaseFirestore

class NotificationViewModel: ObservableObject, NotificationInitDelegate, NotificationServiceDelegate {
    @Published var notifications: [Notification] = []
    private var notificationService: NotificationService
    private var authenticationService: AuthenticationService
    
    
    init(notificationService: NotificationService, authenticationService: AuthenticationService) {
        self.notificationService = notificationService
        self.authenticationService = authenticationService
        
        self.notificationService.notificationServiceDelegate = self
        self.authenticationService.notificationInitDelegate = self
    }
        
    func onNotificationInit() {
        DispatchQueue.main.async {
            print("initializing notifications")
            self.notifications = []
        }
    }
    
    func onNotificationAdded(notificationId: String, notification: Notification) {
        DispatchQueue.main.async {
            print(#function, "Document added")
            self.notifications.append(notification)
        }
    }
    
    func onNotificationUpdated(notificationId: String, notification: Notification) {
        DispatchQueue.main.async {
            //replace existing object with updated one
            print(#function, "notification modified")
            
            let matchedIndex = self.notifications.firstIndex(where: {($0.id?.elementsEqual(notificationId))!})
            print("match index is \(matchedIndex)")
            
            if (matchedIndex != nil){
                self.notifications[matchedIndex!] = notification
            }
        }
    }
    
    func onNotificationRemoved(notificationId: String, notification: Notification) {
        DispatchQueue.main.async {
            //remove object from index in bookList
            print(#function, "Document removed")
            
            let matchedIndex = self.notifications.firstIndex(where: {($0.id?.elementsEqual(notificationId))!})
            print("match index is \(matchedIndex)")
            
            if (matchedIndex != nil){
                self.notifications.remove(at: matchedIndex!)
            }
        }
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
        
        notificationService.sendRequestSentNotification(receiverId: by, by: target)
        notificationService.sendRequestReceivedNotification(receiverId: target, target: by)
    }
    
    func notificationRead(userId: String, notificationId: String) {
        notificationService.notificationRead(userId: userId, notificationId: notificationId)
    }
    
    func rejectFollowRequest(from: String, by: String) {
        notificationService.sendRejectedNotification(receiverId: by, by: from)
    }
    
    func actionDone(userId: String, notificationId: String) {
        notificationService.actionDone(userId: userId, notificationId: notificationId)
    }
    
    func testing(receiverId: String) {
        notificationService.testing(receiverId: receiverId)
    }
}
