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
    @Binding var rootScreen: RootViews
    
    var body: some View {
        VStack{
            TabView {
                MapView().tabItem {
                    Image(systemName: "map")
                    Text("Map") //Map
                }
                
                FollowingListView().tabItem {
                    Image(systemName: "person")
                    Text("Following") //Following
                }
                
                FollowedByListView().tabItem {
                    Image(systemName: "eye")
                    Text("Followed By") //Followed By
                }
            }
        }
     }

}

//#Preview {
//    MainView()
//}
