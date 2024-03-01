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
//    @State private var errorType: UserError? = nil
//    @State private var showSucessAlert: Bool = false
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UserError>? = nil
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("User Email/Phone: ")
                    TextField("", text: $userToFollow)
                }
            }
            
            HStack {
                Button {
                    print("add button pressed")
                    
    //                        notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.id)
                    Task {
                        do {
                            print("request sending")
                            try await notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.identifier)
//                            showSucessAlert.toggle()
                            sentResult = .success(())
                            showAlert.toggle()
                        }
                        catch let error as UserError {
                            print("catching error in adding friend view")
//                            errorType = error
                            sentResult = .failure(error)
                            showAlert.toggle()
                        }
                        catch let error {
                            print("error in add friend view \(error)")
//                            errorType = .unknown
                            sentResult = .failure(.unknown)
                            showAlert.toggle()
                        }
                    }
                } label: {
                    Text("Invite")
                }
//                .alert(item: $errorType){ error in
//                    let errMsg: String
//                    switch error {
//                    case .cannotBeYourself:
//                        errMsg = "Cannot follow yourself"
//                    case .alreadyFollowed:
//                        errMsg = "You have already followed this user"
//                    case .invalidUser:
//                        errMsg = "User not Found"
//                    default:
//                        errMsg = "Unknown error"
//                    }
//                    return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
//                }
//                .alert(isPresented: $showSucessAlert){
//                    Alert(title: Text("Invitation Sent"), message: Text("Waiting for the user to accept"))
//                }
                .alert(isPresented: $showAlert) {
                    switch sentResult {
                    case .success:
                        return Alert(title: Text("Invitation Sent"), message: Text("Waiting for the user to accept"))
                    case .none:
                        return Alert(title: Text("Unknown"), message: Text("Unknown"))
                    case .failure(let error):
                        let errMsg: String
                        switch error {
                        case .cannotBeYourself:
                            errMsg = "Cannot follow yourself"
                        case .alreadyFollowed:
                            errMsg = "You have already followed this user"
                        case .invalidUser:
                            errMsg = "User not Found"
                        default:
                            errMsg = "Unknown error"
                        }
                    
                        return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
                    }
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

//#Preview {
//    AddFriendView()
//}
