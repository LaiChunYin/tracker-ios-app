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
                MapView(position: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 32.8236,
                                                                                             longitude: -96.7166),
                                                    distance: 1000,
                                                    heading: 250,
                                                    pitch: 80))).tabItem {
                    Image(systemName: "map")
                    Text("m") //Map
                }
                
                FollowingListView().tabItem {
                    Image(systemName: "person")
                    Text("f") //Following
                }
                
                FollowedByListView().tabItem {
                    Image(systemName: "eye")
                    Text("fb") //Followed By
                }
            }
        }
     }

}

//#Preview {
//    MainView()
//}
