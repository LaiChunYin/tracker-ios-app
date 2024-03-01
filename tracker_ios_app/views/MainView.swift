//
//  MainView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var rootScreen: RootViews
    
    var body: some View {
        NavigationView {
            TabView {
                MapView().tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                
                FollowingListView().tabItem {
                    Image(systemName: "person")
                    Text("Following")
                }
                
                FollowedByListView().tabItem {
                    Image(systemName: "eye")
                    Text("Followed By")
                }
            }
            .navigationTitle(userViewModel.currentUser != nil ? "Welcome, \(userViewModel.currentUser!.identifier)" : "Logging out")
            .navigationBarTitleDisplayMode(.inline)
        }


     }

}

//#Preview {
//    MainView()
//}
