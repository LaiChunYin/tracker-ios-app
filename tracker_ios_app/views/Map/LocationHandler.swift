//
//  LocationHandler.swift
//  tracker_ios_app
//
//  Created by Gaurav Rawat on 2024-03-05.
//

import Foundation
import MapKit

@MainActor 
class LocationsHandler: ObservableObject {
    private let manager: CLLocationManager
    @Published var lastLocation = CLLocation()
    @Published var updates = CLLocationUpdate.liveUpdates()
    
    init() {
        self.manager = CLLocationManager() // Safe to call in MainActor
        self.manager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
         Task(){
            do {
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if let loc = update.location {
                        // Assigning the received location to lastLocation
                        self.lastLocation = loc
                        print("location: \(loc)")
                    }
                }
            }catch { /* handle errors */ }
                return
            }
        }
    }

