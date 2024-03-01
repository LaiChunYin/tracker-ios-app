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
    @State private var errorType: UserError? = nil
    
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
                            let userToBeDeleted = followedBy[index]
                            
                            do {
                                try userViewModel.unfollow(followerId: userToBeDeleted, targetId: userViewModel.currentUser!.identifier, isRemovingFollower: true)
                                followedBy.remove(at: index)
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
                        case .notFollowedBy:
                            errMsg = "This user is not following you"
                        case .invalidUser:
                            errMsg = "User not Found"
                        default:
                            errMsg = "Unknown error"
                        }
                        return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
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
