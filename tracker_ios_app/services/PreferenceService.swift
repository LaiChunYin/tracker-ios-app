//
//  PreferenceService.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import Foundation


class PreferenceService {
    var isRememberLoginStatus: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.REMEMBER_ME)
        }
        
        set(value) {
            UserDefaults.standard.set(value, forKey: UserDefaultsKeys.REMEMBER_ME)
        }
    }
    
    var geofenceRadiusInMeters: Double {
        get {
            return UserDefaults.standard.double(forKey: UserDefaultsKeys.GEOFENCE_RADIUS)
        }
        
        set(value) {
            UserDefaults.standard.set(value, forKey: UserDefaultsKeys.GEOFENCE_RADIUS)
        }
    }
}
