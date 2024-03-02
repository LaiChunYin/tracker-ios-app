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
                MapView(position: MKCoordinateRegion(center: CLLocationCoordinate2D(
                    latitude: 40.7608,
                    longitude: -111.8910),
                    span: MKCoordinateSpan(latitudeDelta: 0.5,
                    longitudeDelta: 0.5))).tabItem {
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
