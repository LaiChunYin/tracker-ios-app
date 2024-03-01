//
//  FollowedByListView.swift
//  tracker_ios_app
//
//  Created by macbook on 27/2/2024.
//

import SwiftUI


struct FollowedByListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State var followedBy: [String] = []
    @State var isFollowedByNone: Bool = false

    var body: some View {
        NavigationView {

            VStack {
                if(isFollowedByNone){
                    Text("Not followed by anyone yet 🙂")
                }
                else{
                    List {
                        ForEach(followedBy, id: \.self) { followedBy in
                            FriendListItemView(user: followedBy, icon: "location.fill")
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
                    .navigationTitle("Fb page") //Followed By
                    .onAppear() {
                        followedBy = userViewModel.currentUser?.userData?.followedBy.keys.map {$0} ?? []
                        if(followedBy.isEmpty){
                            isFollowedByNone = true
                        }else{
                            isFollowedByNone = false
                        }
                    }

                }
            }
        }
           
    }
}


//#Preview {
//    FollowedByListView(followedBy: ["user1"])
//        .preferredColorScheme(.dark)
//}
