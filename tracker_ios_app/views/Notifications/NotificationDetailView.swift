//
//  NotificationDetailView.swift
//  tracker_ios_app
//
//  Created by macbook on 26/2/2024.
//

import SwiftUI

struct NotificationDetailView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    var notification: Notification
    var dateFormatter: DateFormatter
    @State private var errorType: UserError? = nil
    
    init(notification: Notification) {
        self.notification = notification
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy (EEEE) HH:mm:ss"
    }
    
    var body: some View {
        VStack {
            Text("\(notification.title)")
            Text("At: \(dateFormatter.string(from: notification.time))")
            Divider()
            Text("\(notification.content)")
            
            
            switch notification.type {
                case .invitationReceived:
                    HStack {
                        Button {
                            do {
                                try userViewModel.follow(followerId: notification.extraData["follower"]!, targetId: userViewModel.currentUser!.identifier)
                                
                                notificationViewModel.actionDone(userId: userViewModel.currentUser!.identifier, notificationId: notification.id!)
                            }
                            catch let error as UserError {
                                print("error notification detail view \(error)")
                                errorType = error
                            }
                            catch let error {
                                errorType = .unknown
                            }
                        } label: {
                            Text("Accept")
                        }
                        .disabled(notification.actionTaken!)
                        .alert(item: $errorType){ error in
                            let errMsg: String
                            switch error {
                            case .alreadyFollowed:
                                errMsg = "You have already followed this user"
                            case .invalidUser:
                                errMsg = "User not Found"
                            default:
                                errMsg = "Unknown error"
                            }
                            return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
                        }
                        
                        Button {
                            notificationViewModel.rejectFollowRequest(from: notification.extraData["follower"]!, by: userViewModel.currentUser!.identifier)
                            
                            notificationViewModel.actionDone(userId: userViewModel.currentUser!.identifier, notificationId: notification.id!)
                        } label: {
                            Text("Reject")
                        }
                        .disabled(notification.actionTaken!)
                    }
                default:
                    EmptyView()
                }
        }
        .onAppear() {
            print("read")
//            notificationViewModel.notificationRead(notificationId: notification.id!)
            if !notification.read {
                notificationViewModel.notificationRead(userId: userViewModel.currentUser!.identifier, notificationId: notification.id!)
            }
        }
    }
}

//#Preview {
//    NotificationDetailView()
//}
