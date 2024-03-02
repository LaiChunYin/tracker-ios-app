//
//  FollowingListView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
//    @State private var followings: [String] = []
    @State private var followings: [(key: String, value: UserItemSummary)] = []
    @State private var errorType: UserError? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if(followings.isEmpty){
                    Text("Not following anyone yet 🙂")
                }
                else {
                    List {
                        ForEach(followings, id: \.key) { follower, userItemSummary in
                            FriendListItemView(userId: follower, userItemSummary: userItemSummary, icon: "location.magnifyingglass")
                        }
                        .onDelete { indexSet in
                            print("deleting \(indexSet)")
                            for index in indexSet {
                                let userToBeDeleted = followings[index].key
                                
                                do {
                                    try userViewModel.unfollow(followerId: userViewModel.currentUser!.identifier, targetId: userToBeDeleted, isRemovingFollower: false)
                                    followings.remove(at: index)
                                }
                                catch let error as UserError {
                                    errorType = error
                                }
                                catch let error {
                                    print("error in following list view \(error)")
                                    errorType = .unknown
                                }
                            }
                        }
                        .navigationTitle("Following") //Following
                        .alert(item: $errorType){ error in
                            let errMsg: String
                            switch error {
                            case .notFollowing:
                                errMsg = "You are not following this user"
                            case .invalidUser:
                                errMsg = "User not Found"
                            default:
                                errMsg = "Unknown error"
                            }
                            return Alert(title: Text("Failed to remove user"), message: Text(errMsg))
                        }
                    }
                }
            }
            .onAppear() {
                print("following list appear")
                
//                followings = userViewModel.currentUser?.userData?.following.keys.map {$0} ?? []
                followings = userViewModel.currentUser?.userData?.following.sorted {$0.value.connectionTime > $1.value.connectionTime} ?? []
                
                print("following is \(followings)")
            }
        }
    }
}
//#Preview {
//    FollowerListView()
//}

