//
//  LocationViewModel.swift
//  tracker_ios_app
//
//  Created by macbook on 7/3/2024.
//

import Foundation
import CoreLocation

class LocationViewModel: ObservableObject, LocationServiceDelegate {
    @Published var currentLocation: Waypoint? = nil
    @Published var locationSnapshots: [Waypoint] = []
    @Published var snapshotsOfFollowings: [String: [Waypoint]] = [:]
    @Published var currentWeather: Weather? = nil
    @Published var displayingLocation: Waypoint? = nil
    private var locationService: LocationService
    private var weatherService: WeatherService
    private var notificationService: NotificationService
    private var preferenceService: PreferenceService
    var maxTimeDiffBetween2Points: Double {
        preferenceService.maxTimeDiffBetween2Points
    }
    var geofenceRadius: Double {
        preferenceService.geofenceRadiusInMeters
    }
    @Published var currentUserGeofence: (String, CLLocationCoordinate2D, CLLocationDistance)? = nil  // (current user id, current user's location, radius of geofence zone)
    private var previousGeofenceOfUsers: [String: (String, CLLocationCoordinate2D, CLLocationDistance)] = [:] // this is for detecting user enter/exit events
    
    
    init(locationService: LocationService, weatherService: WeatherService, notificationService: NotificationService, preferenceService: PreferenceService) {
        self.locationService = locationService
        self.weatherService = weatherService
        self.notificationService = notificationService
        self.preferenceService = preferenceService
        
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
        
        print("before keeping self locations: \(self.locationSnapshots.count)")
        self.locationSnapshots = self.keepOnlyLatestLocations(originalWaypoints: self.locationSnapshots, newWaypoints: waypoints, timeRange: maxTimeDiffBetween2Points)
        print("after keeping self locations: \(self.locationSnapshots.count)")
        
        if waypoints.last != nil{
            self.currentLocation = waypoints.last!
        }
        else {
            self.currentLocation = waypoints.first!
        }
        
        if let (userId, _, _) = self.currentUserGeofence {
            self.currentUserGeofence = (userId, CLLocationCoordinate2D(latitude: self.currentLocation!.latitude, longitude: self.currentLocation!.longitude), CLLocationDistance(geofenceRadius))
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
            
            if self.currentUserGeofence != nil {
                self.checkUserInGeofenceRegion(userId: userId)
                self.previousGeofenceOfUsers[userId] = self.currentUserGeofence
            }
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
    
    func focusAt(location: Waypoint?) {
        print("changing focus")
        displayingLocation = location
    }
    
    func startGeofencingCurrentUser(userId: String) {
        let center = self.currentLocation
        let radius = geofenceRadius
        self.currentUserGeofence = (userId, CLLocationCoordinate2D(latitude: center!.latitude, longitude: center!.longitude), CLLocationDistance(radius))
    }
    
    /*
     Detect Enter/Exit by checking if the previous location was in the previous region and if the current location is in the current location. The checking is done only when the following users update their location
     Limitations:
     1. if the current user or the following user moves too fast, the following user may be cutting through the region without being detected
     */
    func checkUserInGeofenceRegion(userId: String) {
            if let (currentUserId, center, radius) = self.currentUserGeofence {
                print("checking region \(center), \(radius)")
                var previousRegion: CLCircularRegion? = nil
                
                let currentRegion = CLCircularRegion(center: center, radius: radius, identifier: "currentUserGeofence")
                
                if let (_, center, radius) = self.previousGeofenceOfUsers[userId] {
                    print("checking previous region, \(center), \(radius)")
                    previousRegion = CLCircularRegion(center: center, radius: radius, identifier: "previousUserGeofence")
                }
                
                if let waypoints = self.snapshotsOfFollowings[userId], let lastWaypoint = waypoints.last {
                    let secondLastWaypoint: Waypoint? = waypoints[waypoints.count - 2]
                    if Double(Int(lastWaypoint.time.timeIntervalSinceNow) % 60) >= 20 {
                        print("location not updated enough")
                    }
                    
                    let islastLocationInRegion = currentRegion.contains(CLLocationCoordinate2D(latitude: lastWaypoint.latitude, longitude: lastWaypoint.longitude))
                    
                    let isSecondLastLocationInRegion = secondLastWaypoint != nil && previousRegion != nil ? previousRegion!.contains(CLLocationCoordinate2D(latitude: secondLastWaypoint!.latitude, longitude: secondLastWaypoint!.longitude)) : false
                    
                    print("is in region? \(islastLocationInRegion), \(isSecondLastLocationInRegion)")
                    
                    if islastLocationInRegion && !isSecondLastLocationInRegion {
                        print("entering region")
                        notificationService.sendEnteredGeofencingZoneNotification(receiverId: currentUserId, target: userId, radius: self.geofenceRadius)
                    }
                    if !islastLocationInRegion && isSecondLastLocationInRegion {
                        print("exiting region")
                        notificationService.sendExitedGeofencingZoneNotification(receiverId: currentUserId, target: userId, radius: self.geofenceRadius)
                    }
                }
        }
    }
    
    func stopGeofencingCurrentUser() {
        print("stop geofencing")
        self.currentUserGeofence = nil
//        self.previousUserGeofence = nil
        self.previousGeofenceOfUsers = [:]
    }
    
    func updateGeofenceRadius(radius: Double) {
        preferenceService.geofenceRadiusInMeters = radius
    }

    func updateMaxTimeDiffBetween2Points(timeDiff: Double) {
        preferenceService.maxTimeDiffBetween2Points = timeDiff
    }
}
