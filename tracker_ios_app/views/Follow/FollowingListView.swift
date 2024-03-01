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
    @State private var errorType: UserError? = nil
    
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
                            let userToBeDeleted = followers[index]
                            
                            do {
                                try userViewModel.unfollow(followerId: userViewModel.currentUser!.identifier, targetId: userToBeDeleted, isRemovingFollower: false)
                                followers.remove(at: index)
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
                        return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
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
