//
//  AddFriendView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct AddFriendView: View {
    @State private var userToFollow: String = ""
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var showAddFriendForm: Bool
    
    var body: some View {
        Form {
            VStack {
                VStack(alignment: .leading) {
                    Text("User Email/Phone: ")
                        .padding(.top)
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.purple)
                        TextField("", text: $userToFollow)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 2)
                        
                    }
                    .frame(height: 40)
                    .padding(.trailing)
                }
                
                HStack {
                    Button {
                      notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.identifier)
                    } label: {
                        Text("Invite")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showAddFriendForm.toggle()
                    } label: {
                        Text("Cancel")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .fontWeight(.semibold)
                }
                .padding()
                
                Spacer()
                
                Button("Dismiss"){showAddFriendForm = false}
                    .accentColor(.purple)
                    .padding(.bottom)
            }
        }
    }
}

//#Preview {
//    AddFriendView()
//        .preferredColorScheme(.dark)
//}



//struct AddFriendView: View {
//    @EnvironmentObject var notificationViewModel: NotificationViewModel
//    @EnvironmentObject var userViewModel: UserViewModel
//    @State private var userToFollow: String = ""
//    @Binding var showAddFriendForm: Bool
//    
//    var body: some View {
//        Form {
//            VStack {
//                HStack {
//                    Text("User Email/Phone: ")
//                    TextField("", text: $userToFollow)
//                }
//                
//                HStack {
//                    Button {
//                        print("add button pressed")
//                        
////                        notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.id)
//                        notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.identifier)
//                    } label: {
//                        Text("Invite")
//                    }
//                    
//                    Button {
//                        print("cancel button pressed")
//                        showAddFriendForm.toggle()
//
//                    } label: {
//                        Text("Cancel")
//                    }
//                }
//            }
//        }
//    }
//}
