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
    
    init(notification: Notification) {
        self.notification = notification
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy (EEEE) HH:mm:ss"
    }
    
    var body: some View {
        VStack {
            
            Text("\(notification.title)")
                .font(.title)
                .padding(.top, 40)
            
            Text("At: \(dateFormatter.string(from: notification.time))")
                .font(.caption)
                .foregroundStyle(.orange)
            Divider()
            Text("\(notification.content)")
                .font(.footnote)
                .padding(.horizontal, 6)
                .multilineTextAlignment(.leading)
            
            switch notification.type {
                case .invitationReceived:
                    HStack {
                        Button {
//                            notificationViewModel.acceptFollowRequest(receiverId: notification.extraData["follower"]!, by: userViewModel.currentUser!.id)
                            notificationViewModel.acceptFollowRequest(receiverId: notification.extraData["follower"]!, by: userViewModel.currentUser!.identifier)
//                            userViewModel.follow(followerId: notification.extraData["follower"]!, targetId: userViewModel.currentUser!.id)
                            userViewModel.follow(followerId: notification.extraData["follower"]!, targetId: userViewModel.currentUser!.identifier)
                            
                            notificationViewModel.actionDone(userId: userViewModel.currentUser!.identifier, notificationId: notification.id!)
                        } label: {
                            Text("Accept")
                        }
                        .disabled(notification.actionTaken!)
                        .buttonStyle(.bordered)
                       
                        
                        Spacer()
                        
                        
                        Button {
//                            notificationViewModel.rejectFollowRequest(receiverId: notification.extraData["follower"]!, by: userViewModel.currentUser!.id)
                            notificationViewModel.rejectFollowRequest(receiverId: notification.extraData["follower"]!, by: userViewModel.currentUser!.identifier)
                            
                            notificationViewModel.actionDone(userId: userViewModel.currentUser!.identifier, notificationId: notification.id!)
                        } label: {
                            Text("Reject")
                        }
                        .disabled(notification.actionTaken!)
                        .foregroundColor(.red)
                        .buttonStyle(.bordered)
                        
                    }
                    .padding(30)
                default:
                    EmptyView()
                }
            
            Spacer()
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
