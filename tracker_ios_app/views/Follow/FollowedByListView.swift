//
//  FollowedByListView.swift
//  tracker_ios_app
//
//  Created by macbook on 27/2/2024.
//

import SwiftUI

struct FollowedByListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var followedBy: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(followedBy, id: \.self) { followedBy in
                        FriendListItemView(user: followedBy)
                    }
                    .onDelete { indexSet in
                        print("deleting \(indexSet)")
                        for index in indexSet {
                            let userToBeDelete = followedBy[index]
                            userViewModel.unfollow(followerId: userToBeDelete, targetId: userViewModel.currentUser!.identifier)
                            followedBy.remove(at: index)
                            
                            let notification = Notification(type: .subscriberRemoved, extraData: ["target": userToBeDelete])
                            userViewModel.sendNotification(receiverId: userToBeDelete, notification: notification)
                        }
                    }
                }
            }
            .navigationTitle("Followed By")
            .onAppear() {
                followedBy = userViewModel.currentUser?.userData?.followedBy.keys.map {$0} ?? []
            }
        }
    }
}

//#Preview {
//    FollowedByListView()
//}
