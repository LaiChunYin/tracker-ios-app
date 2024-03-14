//
//  Waypoints.swift
//  tracker_ios_app
//
//  Created by macbook on 14/3/2024.
//

import Foundation
import CoreLocation

struct Waypoint: Codable, Equatable {
    let longitude: Double
    let latitude: Double
    let time: Date
    
    init(location: CLLocation) {
        print("getting waypoint at \(location.timestamp), now is \(Date.now)")
        self.longitude = Double(location.coordinate.longitude)
        self.latitude = Double(location.coordinate.latitude)
        self.time = location.timestamp
    }
}
