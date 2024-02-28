//
//  FollowingListView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var followers: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(followers, id: \.self) { follower in
                        FriendListItemView(user: follower)
                    }
                    .onDelete { indexSet in
                        print("deleting \(indexSet)")
                        for index in indexSet {
                            let userToBeDelete = followers[index]
                            userViewModel.unfollow(followerId: userViewModel.currentUser!.identifier, targetId: userToBeDelete)
                            followers.remove(at: index)
                            
                        }
                    }
                }
            }
            .navigationTitle("Following")
            .onAppear() {
                followers = userViewModel.currentUser?.userData?.following.keys.map {$0} ?? []
            }
        }
    }
}

//#Preview {
//    FollowerListView()
//}
