//
//  ContentView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var userViewModel = UserViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @State private var showAddFriendForm: Bool = false
    @State var rootScreen: RootViews = .main
    
    var body: some View {
        VStack {
            if userViewModel.currentUser != nil {
                NavigationStack {
                    Group {
                        switch rootScreen {
                        case .main:
                            MainView(rootScreen: $rootScreen).environmentObject(userViewModel).environmentObject(notificationViewModel)
                        case .notifications:
                            NotificationListView(rootScreen: $rootScreen).environmentObject(userViewModel).environmentObject(notificationViewModel)
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            // for testing notification, remove later
                            Button {
                                print("sending test noti")
                                //                                notificationViewModel.testing(receiverId: userViewModel.currentUser!.id)
                                notificationViewModel.testing(receiverId: userViewModel.currentUser!.identifier)
                            } label: {
                                Image(systemName: "exclamationmark.octagon")
                            }
                            
                            Button {
                                print("plus button pressed")
                                showAddFriendForm.toggle()
                            } label: {
                                Image(systemName: "person.badge.plus.fill")
                            }
                            .sheet(isPresented: $showAddFriendForm) {
                                AddFriendView(showAddFriendForm: $showAddFriendForm)
                            }
                            .presentationDetents([.fraction(0.5)])
                            
                            switch rootScreen {
                            case .main:
                                Button {
                                    print("going to notifications")
                                    rootScreen = .notifications
                                } label: {
                                    Image(systemName: "bell.fill")
                                }
                            case .notifications:
                                Button {
                                    print("going to home")
                                    rootScreen = .main
                                } label: {
                                    Image(systemName: "house.fill")
                                }
                            }
                            
                            
                            Menu {
                                Button {
                                    userViewModel.logout()
                                } label: {
                                    Text("Logout")
                                }
                            } label: {
                                Label("More", systemImage: "line.horizontal.3")
                            }
                            
                            
                        }
                    }
                }
                
            }
            else {
                LoginView()
            }
        }
        .padding()

    }
}

#Preview {
    ContentView()
}
