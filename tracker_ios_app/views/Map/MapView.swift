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
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false
    @State var position: MapCameraPosition = .automatic
    @ObservedObject var locationsHandler = LocationsHandler()
    @State var location: CLLocation?
    @State var share: Bool = false
    @State var stop: Bool = false
    @State private var shareColor: Color = .red
    
    enum AnimationState {
        case start
        case stop
    }

    
    var body: some View {
        GeometryReader{ geo in
            Map(position: $position){
//                ForEach(0..<4) { _ in      // MARK: loop here for multiple annotation
                    Annotation("final boss", coordinate: CLLocationCoordinate2D(latitude: location?.coordinate.latitude ?? 0, longitude: location?.coordinate.longitude ?? 0)){
                        Image(systemName: "mappin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .shadow(color: .white, radius: 3)
                            .scaleEffect(x: -1)
                    }
//              }
            }
            .mapStyle( isSatelliteMap ? .imagery(elevation: .realistic) : .standard(elevation: .realistic))
            .toolbarBackground(.automatic)
            .overlay(alignment: .bottomTrailing){
                VStack {
                    Button{
                        Task{
                            share.toggle()
                            if(shareColor == .red){
                                print("Location sharing is on") // MARK: START SHARING LOCATION WITH OTHERS
                            }else{
                                print("Location sharing is off") // // MARK: STOP SHARING LOCATION WITH OTHERS
                            }
                            shareColor = (shareColor == .green) ? .red : .green
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                share.toggle()
                            }
                        }
                    }label: {
                        Image(systemName: "wifi")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .imageScale(.small)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 16)
                            .padding(.bottom, 5)
                            
                    }
                    .popoverTip(MapTip(), arrowEdge: .top)

                    BottomLeftButtonView(isRecenterMap: $isRecenterMap, isSatelliteMap: $isSatelliteMap, position: $position, share: $share, shareColor: $shareColor)
                    
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
            ZStack{
                ZStack {
                    Rectangle()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(share ? shareColor.opacity(0.6) : .clear)
                        .animation(.easeInOut, value: share)
                    if share {
                               GridPattern()
                           }
                       }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .onAppear{
                Task{
                    // MARK: Run query here to store data in firebase
                    try? Tips.configure()
                    print("onAppear started")
                    locationsHandler.startLocationUpdates()
                    for try await update in locationsHandler.updates{
                        print("my location is : \(update.location)")
                        location = update.location
                        print("latitude : \(location?.coordinate.latitude)")
                        print("longitude : \(location?.coordinate.longitude)")
                    }
                }
            }
        }
            .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    MapView()
        .preferredColorScheme(.dark)
}

struct BottomLeftButtonView: View {
    @Binding var isRecenterMap: Bool
    @Binding var isSatelliteMap: Bool
    @Binding var position: MapCameraPosition
    @Binding var share: Bool
    @Binding var shareColor: Color
    
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
