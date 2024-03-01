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
//    @State private var isFollowedBy: Bool = false
    
    var body: some View {
        NavigationView {
           
            VStack {
                List {
                    ForEach(followedBy, id: \.self) { followedBy in
                        FindUserView(user: followedBy, icon: "location.fill")
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
            .navigationTitle("Fb page") //Followed By
            .onAppear() {
                followedBy = userViewModel.currentUser?.userData?.followedBy.keys.map {$0} ?? []
//                if(followedBy.isEmpty){
//                    isFollowedBy = true
//                }
//                else{
//                    isFollowedBy = false
//                }
            }
        }
//            if(isFollowedBy){
//                VStack(alignment: .center){
//                    Text("Not followed by anyone yet 🙂")
//                }
//            }
    }
}

//#Preview {
//    FollowedByListView()
//}


struct FindUserView: View {
    var user: String = ""
    var icon: String
    
    var body: some View {
        VStack{
            
            HStack {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text(user)
                }
                Spacer()
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 5)
            
//            Divider()
            
            HStack {
                Text("id: #12003")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("joined: 12-1-2024")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}
