//
//  MapView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit

enum MapDetail{
    static let defaultLocation = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
}

struct MapView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false
    
    @State private var annotations: [MKPointAnnotation] = []
    
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear{
                locationManager.requestLocation()
                addSampleAnnotations()
            }
            .mapStyle( isSatelliteMap ? .imagery(elevation: .realistic) : .standard(elevation: .realistic) )
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
            .onChange(of: isRecenterMap) { newValue in
                isRecenterMap = false
                if newValue {
                    self.region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 37.7749, longitude:  -122.4194),
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
            }
        }
    }
    
    private func addSampleAnnotations() {
            let annotation1 = MKPointAnnotation()
            annotation1.title = "Annotation 1"
            annotation1.coordinate = CLLocationCoordinate2D(latitude: 37.775, longitude: -122.419)

            let annotation2 = MKPointAnnotation()
            annotation2.title = "Annotation 2"
            annotation2.coordinate = CLLocationCoordinate2D(latitude: 37.770, longitude: -122.421)

            annotations.append(annotation1)
            annotations.append(annotation2)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
    }
}
