//
//  LocationViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 7/3/2024.
//

import Foundation
import CoreLocation

class LocationViewModel: ObservableObject, LocationServiceDelegate {
//    @Published var currentLocation: CLLocation
    @Published var currentLocation: Waypoint? = nil
    @Published var locationSnapshots: [Waypoint] = []
    @Published var snapshotsOfFollowings: [String: [Waypoint]] = [:]
    @Published var currentWeather: Weather? = nil
    private var locationService: LocationService
    private var weatherService: WeatherService
    private let maxTimeDiffBetween2Points: Double = 60
    
    
//    init(currentLocation: CLLocation, locationSnapshots: [Waypoint], snapshotsOfFollowings: [String : [Waypoint]], locationService: LocationService) {
    init(locationService: LocationService, weatherService: WeatherService) {
//        self.currentLocation = currentLocation
//        self.locationSnapshots = locationSnapshots
//        self.snapshotsOfFollowings = snapshotsOfFollowings
        self.locationService = locationService
        self.weatherService = weatherService
        
        self.locationService.locationServiceDelegate = self
        print("after loc view model init")
    }
    
    // assume the both waypoints array are already sorted and are already having the latest points
    func keepOnlyLatestLocations(originalWaypoints: [Waypoint], newWaypoints: [Waypoint], timeRange: Double?) -> [Waypoint] {
        guard newWaypoints.count > 0 else {
            print("no points to add")
            return originalWaypoints
        }
        
        guard let timeRange = timeRange else {
            print("keep all locations")
            return originalWaypoints + newWaypoints
        }
        
        for index in stride(from: newWaypoints.count - 1, to: 0, by: -1) {
            let currentPoint = newWaypoints[index]
            let previousPoint = newWaypoints[index - 1]
            print("time diff is \(Double(Int(currentPoint.time.timeIntervalSince(previousPoint.time)) % 60)) seconds")
            
            if Double(Int(currentPoint.time.timeIntervalSince(previousPoint.time)) % 60) >= timeRange {
                print("break new waypoints")
                return Array(newWaypoints.suffix(index))
            }
        }
        
        guard originalWaypoints.count > 0 else {
            print("no points to keep")
            return newWaypoints
        }
        
        print("time diff of old and new is \(Double(Int(newWaypoints.first!.time.timeIntervalSince(originalWaypoints.last!.time)) % 60)) seconds")
        
        if Double(Int(newWaypoints.first!.time.timeIntervalSince(originalWaypoints.last!.time)) % 60) >= timeRange {
            print("exceed time range")
            return newWaypoints
        }
        
        return originalWaypoints + newWaypoints
        
    }
    
    func onLocationServiceReset() {
        print("resetting location view model")
        self.currentLocation = nil
        self.locationSnapshots = []
        self.snapshotsOfFollowings = [:]
        self.currentWeather = nil
    }
    
    func onFollowingRemoved(userId: String) {
        print("removing following \(userId) in location view model")
        self.snapshotsOfFollowings.removeValue(forKey: userId)
    }
    
    func onSelfLocationUpdated(waypoints: [Waypoint]) {
        print("before self location updated")
        
//        self.locationSnapshots.append(contentsOf: waypoints)
        print("before keeping self locations: \(self.locationSnapshots.count)")
        self.locationSnapshots = self.keepOnlyLatestLocations(originalWaypoints: self.locationSnapshots, newWaypoints: waypoints, timeRange: maxTimeDiffBetween2Points)
        print("before keeping self locations: \(self.locationSnapshots.count)")
        
        if waypoints.last != nil{
            //most recent
//            print(#function, "most recent location : \(waypoints.last!)")
            
            self.currentLocation = waypoints.last!
        }else{
            //oldest known location
//            print(#function, "last known location : \(waypoints.first)")
            
            self.currentLocation = waypoints.first!
        }
    }
    
    func onLocationAdded(userId: String, waypoint: Waypoint) {
        print("before adding location, \(userId), \(waypoint)")
        if var waypoints = self.snapshotsOfFollowings[userId] {
//            waypoints.append(waypoint)
            print("before keeping locations: \(waypoints.count)")
            waypoints = self.keepOnlyLatestLocations(originalWaypoints: waypoints, newWaypoints: [waypoint], timeRange: maxTimeDiffBetween2Points)
            print("after keeping locations: \(waypoints.count)")
            self.snapshotsOfFollowings[userId] = waypoints
        }
        print("after adding location")
    }
    
    
    func onLocationInit(userId: String) {
        print("initing following in locationview model")
        self.snapshotsOfFollowings[userId] = []
    }
    
    func startLocationUpdates() throws {
        do {
            print("before start location update")
            try locationService.startLocationUpdates()
            print("after start location update")
        }
        catch let error {
            print("error in start location updates: \(error)")
            throw error
        }
        
    }
    
    func startSavingSnapshots(userId: String) {
        print("before start saving snapshots")
        locationService.startSavingSnapshots(userId: userId, interval: 10)
        print("after start saving snapshots")
    }
    
    func stopSavingSnapshots() {
        locationService.stopSavingSnapshots()
    }
    
    func getLocationDetails(latitude: Double, longitude: Double) async {
        do {
            let weather = try await weatherService.getWeatherFromAPI(latitude: latitude, longitude: longitude)
            
            DispatchQueue.main.async {
                self.currentWeather = weather
            }
        }
        catch let error {
            print("cannot get weather \(error)")
        }
    }
}
