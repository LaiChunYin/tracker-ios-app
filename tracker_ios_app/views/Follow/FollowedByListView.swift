//
//  FollowedByListView.swift
//  tracker_ios_app
//
//  Created by macbook on 27/2/2024.
//

import SwiftUI


struct FollowedByListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
//    @State private var followedByList: [String] = []
    @State private var followedByList: [(key: String, value: UserItemSummary)] = []
    @State private var errorType: UserError? = nil
    
    var body: some View {
        NavigationView {

            VStack {
                if(followedByList.isEmpty) {
                    Text("Not followed by anyone yet 🙂")
                }
                else {
                    List {
                        ForEach(followedByList, id: \.key) { followedBy, userItemSummary in
                            FriendListItemView(userId: followedBy, userItemSummary: userItemSummary, icon: "location.fill")
                        }
                        .onDelete { indexSet in
                            print("deleting \(indexSet)")
                            for index in indexSet {
                                let userToBeDeleted = followedByList[index].key
                                
                                do {
                                    try userViewModel.unfollow(followerId: userToBeDeleted, targetId: userViewModel.currentUser!.identifier, isRemovingFollower: true)
                                    followedByList.remove(at: index)
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
                        .navigationTitle("Followed By") //Followed By
                        .alert(item: $errorType) { error in
                            let errMsg: String
                            switch error {
                            case .notFollowedBy:
                                errMsg = "This user is not following you"
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
//                followedByList = userViewModel.currentUser?.userData?.followedBy.keys.map {$0} ?? []
                
                followedByList = userViewModel.currentUser?.userData?.followedBy.sorted {$0.value.connectionTime > $1.value.connectionTime} ?? []
            }
        }
           
    }
}


//#Preview {
//    FollowedByListView(followedBy: ["user1"])
//        .preferredColorScheme(.dark)
//}
