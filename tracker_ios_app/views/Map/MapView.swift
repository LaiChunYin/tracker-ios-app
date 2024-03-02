//
//  MapView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit

enum MapDetail{
    static let defaultLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7608, longitude: -111.8910), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    static let defaultCoordinate = CLLocationCoordinate2D(latitude: 40.7608, longitude: -111.8910)
}

struct MapView: View {
    @State private var viewModel = MapViewModel()
    @State var position: MKCoordinateRegion
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false

    @State private var mapCoordinate = MKCoordinateRegion(center: CLLocationCoordinate2D(
    latitude: 40.7608,
    longitude: -111.8910),
    span: MKCoordinateSpan(latitudeDelta: 0.5,
    longitudeDelta: 0.5))
    
    
    
    var body: some View {
        Map{
            Annotation("here", coordinate: MapDetail.defaultCoordinate){
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
        .onAppear{
            viewModel.checkIfLocationServicesIsEnabled()
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
                        position = MapDetail.defaultLocation
                    }
        }
    }
}


#Preview {
    MapView(position: MapDetail.defaultLocation)
    .preferredColorScheme(.dark)
}


final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
 
    var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled(){
     
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("location permission not granted")
        }
    }
    
    private func checkLocationAuthorization(){
        
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted. Please change from setting.")
        case .denied:
            print("You've denied location. Please change from setting.")
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
