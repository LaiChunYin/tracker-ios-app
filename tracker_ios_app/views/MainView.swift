//
//  MainView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var sharedViewModel: SharedViewModel
    @Binding var rootScreen: RootViews
    
    var body: some View {
        VStack{
            TabView(selection: $sharedViewModel.tabSelection) {
                MapView().environmentObject(locationViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map") //Map
                }
                .tag(0)
                
                FollowingListView().environmentObject(userViewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Following") //Following
                }
                .tag(1)
                
                FollowedByListView().environmentObject(userViewModel).environmentObject(notificationViewModel)
                .tabItem {
                    Image(systemName: "eye")
                    Text("Followed By") //Followed By
                }
                .tag(2)
                
//                SelectedShareView().environmentObject(userViewModel).tabItem {
//                    Image(systemName: "shareplay")
//                    Text("Selected Share") //Selected Share
//                }
                
            }
            .navigationTitle(userViewModel.currentUser?.userData != nil ? "Welcome, \(userViewModel.currentUser!.userData!.nickName)" : "Logging out")
            .navigationBarTitleDisplayMode(.inline)
        }
     }

}

//#Preview {
//    MainView()
//}
