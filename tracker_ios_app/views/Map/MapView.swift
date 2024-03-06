//
//  MapView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit


struct MapView: View {
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false
    @State var position: MapCameraPosition = .automatic
    @ObservedObject var locationsHandler = LocationsHandler()
    @State var location: CLLocation?
    
                                                           
    
    var body: some View {
        GeometryReader{ geo in
            
            Map(position: $position){
//                ForEach(0..<4) { _ in      // loop here for multiple annotation
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
                        isRecenterMap = true
                        position = .automatic
                    }label: {
                        Image(systemName: "scope" )
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 20)
                            .padding(.bottom, 5)
                    }
                    Button{
                        isSatelliteMap.toggle()
                    }label: {
                        Image(systemName: isSatelliteMap ? "map.circle.fill" : "map.circle")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                            .imageScale(.large)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding([.bottom, .trailing], 25)
                            .padding(.bottom, geo.size.height/9)
                    }
                }
            }
            .onAppear{
                Task{
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
}
