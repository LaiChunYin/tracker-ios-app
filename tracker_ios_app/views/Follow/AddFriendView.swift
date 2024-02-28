//
//  AddFriendView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var userToFollow: String = ""
    @Binding var showAddFriendForm: Bool
    
    var body: some View {
        Form {
            VStack {
                HStack {
                    Text("User Email/Phone: ")
                    TextField("", text: $userToFollow)
                }
                
                HStack {
                    Button {
                        print("add button pressed")
                        
//                        notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.id)
                        notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.identifier)
                    } label: {
                        Text("Invite")
                    }
                    
                    Button {
                        print("cancel button pressed")
                        showAddFriendForm.toggle()

                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

//#Preview {
//    AddFriendView()
//}
