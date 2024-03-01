//
//  FollowingListView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var followings: [String] = []
    @State var isFollowingNone: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if(isFollowingNone){
                    Text("Not following anyone yet 🙂")
                }
                else{
                    List {
                        ForEach(followings, id: \.self) { follower in
                            //                        FriendListItemView(user: follower)
                            FindUserView(user: follower, icon: "location.magnifyingglass")
                        }
                        .onDelete { indexSet in
                            print("deleting \(indexSet)")
                            for index in indexSet {
                                let userToBeDelete = followings[index]
                                userViewModel.unfollow(followerId: userViewModel.currentUser!.identifier, targetId: userToBeDelete)
                                followings.remove(at: index)
                                
                            }
                        }
                    }
                    
                    .navigationTitle("F page") //Following
                    .onAppear() {
                        followings = userViewModel.currentUser?.userData?.following.keys.map {$0} ?? []
                        if(followings.isEmpty){
                            isFollowingNone = true
                        }else{
                            isFollowingNone = false
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    FollowerListView()
//}

