//
//  NotificationListView.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var rootScreen: RootViews
    
    var body: some View {
//        NavigationView {
        VStack {
//            List(notificationViewModel.notifications ?? []) { notification in
//            List(userViewModel.currentUser?.notifications.sorted { $0.time > $1.time } ?? []) { notification in
            List(notificationViewModel.notifications.sorted { $0.time > $1.time }) { notification in
                NavigationLink {
                    NotificationDetailView(notification: notification).environmentObject(notificationViewModel).environmentObject(userViewModel)
                } label: {
                    NotificationListItemView(notification: notification)
//                    .onTapGesture {
//                        print("reading notification")
//                        notificationViewModel.notificationRead(notificationId: notification.id!)
//                    }
                }
            }
            .onAppear() {
//                print("current user \(userViewModel.currentUser?.id), \(userViewModel.currentUser?.notifications)")
//                print("current user \(userViewModel.currentUser?.identifier), \(userViewModel.currentUser?.notifications)")
                print("current user \(notificationViewModel.notifications)")
            }
            
        }
    }
}

//#Preview {
//    NotificationView()
//}
