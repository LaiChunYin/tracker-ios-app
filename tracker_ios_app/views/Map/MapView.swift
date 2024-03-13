//
//  MapView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit
import TipKit


struct MapView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false
    @State var position: MapCameraPosition = .automatic
//    @State var location: CLLocation?
    @State var isFlashActive: Bool = false
    @State private var isSharing: Bool = false
    @State private var tappedLocation: Waypoint? = nil
    @State private var showLocationDetail = false
    private var dateFormatter: DateFormatter
    @State private var showMapAnnotation = false
    @State private var showAlert = false
    @State private var locationError: LocationServiceError? = nil
    @State private var showPath = false
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    }
        
    var body: some View {
        GeometryReader{ geo in
            Map(position: $position){
                
                if showMapAnnotation && userViewModel.currentUser != nil {
                    // Path of the current user
                    if showPath {
                        MapPolyline(coordinates: locationViewModel.locationSnapshots.sorted { $0.time < $1.time }.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
                            .stroke(.blue, lineWidth: 2.0)
                    }
                    
                    
                    // Paths of the following users
                    ForEach(Array(locationViewModel.snapshotsOfFollowings), id: \.key) { userId, waypoints in
                        if showPath {
                            MapPolyline(coordinates: waypoints.sorted { $0.time < $1.time }.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
                                .stroke(.green, lineWidth: 2.0)
                        }
                        
                        if let lastestLocation = waypoints.last, let nickName = userViewModel.currentUser?.userData?.following[userId]?.nickName {
                            Annotation("\(nickName) at \(dateFormatter.string(from: lastestLocation.time))", coordinate: CLLocationCoordinate2D(latitude: waypoints.last!.latitude, longitude: waypoints.last!.longitude)) {
                                Image(systemName: "mappin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 40)
                                    .shadow(color: .white, radius: 3)
                                    .scaleEffect(x: -1)
                                    .onTapGesture {
                                        print("tapped following")
                                        tappedLocation = waypoints.last!
                                        print("tappedlocation is now \(tappedLocation)")
                                        showLocationDetail.toggle()
                                    }
                            }
                        }
                    }
                    
                    Annotation("You're here", coordinate: CLLocationCoordinate2D(latitude: locationViewModel.currentLocation?.latitude ?? 0, longitude: locationViewModel.currentLocation?.longitude ?? 0)) {
                        Image(systemName: "mappin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .shadow(color: .white, radius: 3)
                            .scaleEffect(x: -1)
                            .onTapGesture {
                                print("tapped yourself")
                                tappedLocation = locationViewModel.currentLocation!
                                print("tappedlocation is now \(tappedLocation)")
                                showLocationDetail.toggle()
                            }
                    }
                }
                
            }
            .mapStyle( isSatelliteMap ? .imagery(elevation: .realistic) : .standard(elevation: .realistic))
            .toolbarBackground(.automatic)
            .overlay(alignment: .bottomTrailing){
                VStack {
                    Button {
                        showPath.toggle()
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.largeTitle)
                            .foregroundColor(showPath ? .green : .red)
                            .imageScale(.small)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 16)
                            .padding(.bottom, 5)
                    }
                    
                    Button{
//                        Task{
//                            share.toggle()
//                            if(shareColor == .red){
//                                print("Location sharing is on") // MARK: START SHARING LOCATION WITH OTHERS
//                            }else{
//                                print("Location sharing is off") // // MARK: STOP SHARING LOCATION WITH OTHERS
//                            }
//                            shareColor = (shareColor == .green) ? .red : .green
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                                share.toggle()
//                            }
//                        }
                        
                        Task{
                            // toggle twice to make a flashing effect
                            isFlashActive.toggle()
                            isSharing.toggle()
                            if isSharing {
                                print("Location sharing is on")
                                locationViewModel.startSavingSnapshots(userId: userViewModel.currentUser!.identifier)
                            }
                            else {
                                print("Location sharing is off")
                                locationViewModel.stopSavingSnapshots()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                isFlashActive.toggle()
                            }
                        }
                        
                    } label: {
                        Image(systemName: "wifi")
                            .font(.largeTitle)
                            .foregroundColor(isSharing ? .green : .red)
                            .imageScale(.small)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 16)
                            .padding(.bottom, 5)
                            
                    }
                    .popoverTip(MapTip(), arrowEdge: .top)

//                    BottomLeftButtonView(isRecenterMap: $isRecenterMap, isSatelliteMap: $isSatelliteMap, position: $position, share: $share, shareColor: $shareColor)
                    RecenterButtonView(isRecenterMap: $isRecenterMap, position: $position)
                    
                    Button{
                        isSatelliteMap.toggle()
                    }label: {
                        Image(systemName: isSatelliteMap ? "map.circle.fill" : "map.circle")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                            .imageScale(.large)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding([.bottom, .trailing], 16)
                            .padding(.bottom, geo.size.height/9)
                    }
                }
            }
            .sheet(isPresented: $showLocationDetail) {
//                LocationDetailsView(waypoint: locationViewModel.locationSnapshots.last!)
                if let tappedLocation = tappedLocation {
                    LocationDetailsView(waypoint: tappedLocation)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.fraction(0.5)])
                }
            }

            
            ZStack{
                // for the flashing screen effect when turning the sharing on/off
                ZStack {
                    Rectangle()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(isFlashActive ? ((isSharing ? .green : .red) as Color).opacity(0.6) : .clear)
                        .animation(.easeInOut, value: isFlashActive)
                    if isFlashActive {
                       GridPattern()
                   }
               }
                .frame(width: geo.size.width, height: geo.size.height)
            }
//            .onAppear{
//                print("start location update")
//                print("snapshot of following \(locationViewModel.snapshotsOfFollowings)")
//                
//                do {
//                    try locationViewModel.startLocationUpdates()
//                    
//                    if isSharing {
//                        print("share location by default")
//                        locationViewModel.startSavingSnapshots(userId: userViewModel.currentUser!.identifier)
//                    }
//                }
//                catch let error as LocationServiceError {
//                    print("cannot start location updates: \(error)")
//                    
//                    showAlert.toggle()
//                    locationError = error
//                }
//                catch let error {
//                    print("unknown location error: \(error)")
//                }
//            }
        }
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $showAlert) {
                var msg: String
                switch locationError {
                    case .locationServicesDisabled:
                        msg = "Location Service is disabled"
                    default:
                        msg = "Cannot start location update. Unknown error."
                }
                return Alert(title: Text("Error"), message: Text(msg))
            }
            .onAppear() {
                print("start location update")
                print("snapshot of following \(locationViewModel.snapshotsOfFollowings)")
                
                do {
                    try locationViewModel.startLocationUpdates()
                    
                    if isSharing {
                        print("share location by default")
                        locationViewModel.startSavingSnapshots(userId: userViewModel.currentUser!.identifier)
                    }
                }
                catch let error as LocationServiceError {
                    print("cannot start location updates: \(error)")
                    
                    showAlert.toggle()
                    locationError = error
                }
                catch let error {
                    print("unknown location error: \(error)")
                }
                
                // delay the map annotations. If showing the annotations immediately after clicking the login button, the application will not be able to make connection with FireAuth for unknown reason
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("delaying map annotations")
                    withAnimation {
                        showMapAnnotation = true
                    }
                }
            }
    }
}


struct RecenterButtonView: View {
    @Binding var isRecenterMap: Bool
    @Binding var position: MapCameraPosition
    
    var body: some View {
        Button{
            isRecenterMap = true
            withAnimation{
                position = .automatic
            }
        }label: {
            Image(systemName: "scope" )
                .font(.largeTitle)
                .foregroundColor(.orange)
                .imageScale(.medium)
                .background(.ultraThinMaterial)
                .clipShape(.circle)
                .padding(.trailing, 16)
                .padding(.bottom, 5)
        }
    }
    
}


struct GridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let rows = 5
                let cols = 5
                let rowSpacing = geometry.size.height / CGFloat(rows)
                let colSpacing = geometry.size.width / CGFloat(cols)
                
                // Draw horizontal grid lines
                for i in 0..<rows {
                    let y = CGFloat(i) * rowSpacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                
                // Draw vertical grid lines
                for i in 0..<cols {
                    let x = CGFloat(i) * colSpacing
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.gray, lineWidth: 1) // Line color and width
        }
    }
}

//#Preview {
//    MapView()
//        .preferredColorScheme(.dark)
//}
