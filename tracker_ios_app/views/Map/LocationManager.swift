////
////  LocationManager.swift
////  tracker_ios_app
////
////  Created by Gaurav Rawat on 2024-03-03.
////
//
//import MapKit
//
//
//class LocationManager: NSObject, ObservableObject {
//    private var manager = CLLocationManager()
//    @Published var userLocation = CLLocation()
//    static let shared = LocationManager()
//    
//    private let locationManager = CLLocationManager()
//    
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.startUpdatingLocation()
//    }
//    
//    func requestLocation() {
//        manager.requestWhenInUseAuthorization()
//    }
//}
//
//extension LocationManager: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        
//        switch status {
//            
//        case .notDetermined:
//            print("notDetermined")
//        case .restricted:
//            print("restricted")
//        case .denied:
//            print("denied")
//        case .authorizedAlways:
//            print("authorizedAlways")
//        case .authorizedWhenInUse:
//            print("authorizedWhenInUse")
//        @unknown default:
//            break
//        }
//        
//        
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        self.userLocation = location
//    }
//}
