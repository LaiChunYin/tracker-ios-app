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
            let value = UserDefaults.standard.double(forKey: UserDefaultsKeys.GEOFENCE_RADIUS)
            
            // tolerenance for comparing floating numbers
            return abs(value) > 1e-8 ? value : 100
        }
        
        set(value) {
            UserDefaults.standard.set(value, forKey: UserDefaultsKeys.GEOFENCE_RADIUS)
        }
    }
    
    var maxTimeDiffBetween2Points: Double {
        get {
            let value = UserDefaults.standard.double(forKey: UserDefaultsKeys.MAX_TIME_DIFF_BTW_2_PTS)
            
            // tolerenance for comparing floating numbers
            return abs(value) > 1e-8 ? value : 60
        }
        
        set(value) {
            UserDefaults.standard.set(value, forKey: UserDefaultsKeys.MAX_TIME_DIFF_BTW_2_PTS)
        }
    }
}
