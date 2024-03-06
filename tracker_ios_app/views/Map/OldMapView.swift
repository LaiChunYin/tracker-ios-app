//
//  OldMapView.swift
//  tracker_ios_app
//
//  Created by Gaurav Rawat on 2024-03-03.
//

import SwiftUI
import MapKit

struct OldMapView: View {
    @State var position: MapCameraPosition
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false // if isRecenterMap is true set the coordinates to default value.
    
    var defaultPosition: MapCameraPosition = .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 32.8236, longitude: -96.7166),
                                                                   distance: 1000,
                                                                   heading: 250,
                                                                   pitch: 80))
    
    var body: some View {
        
        VStack{
            Map(position: $position){
                UserAnnotation()
                
                Annotation("here", coordinate: CLLocationCoordinate2D(latitude: 32.8236, longitude: -96.7166)){
                    Image(systemName: "mappin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                        .shadow(color: .white, radius: 3)
                        .scaleEffect(x: -1)
                        .onTapGesture {
                            
                        }
                }
            }
            .mapStyle( isSatelliteMap ? .imagery(elevation: .realistic) : .standard(elevation: .realistic))
            .overlay(alignment: .bottomTrailing){
                VStack {
                    Button{
                        isRecenterMap = true
                    }label: {
                        Image(systemName: "scope" )
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 15)
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
                            .padding([.bottom, .trailing], 15)
                    }
                }
            }
            .toolbarBackground(.automatic)
            .onChange(of: isRecenterMap) { newValue in
                isRecenterMap = false
                if newValue {
                    position = defaultPosition
                }
            }
        }
    }
}

#Preview {
    OldMapView(position: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 32.8236, longitude: -96.7166),
                                           distance: 1000,
                                           heading: 250,
                                           pitch: 80)))
}
