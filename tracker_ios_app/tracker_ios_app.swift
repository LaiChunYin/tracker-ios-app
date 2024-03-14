//
//  tracker_ios_app.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//


//import SwiftUI
//import FirebaseCore
//
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
//}
//
//@main
//struct YourApp: App {
//  // register app delegate for Firebase setup
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//
//  var body: some Scene {
//    WindowGroup {
//      NavigationView {
//        ContentView()
//      }
//    }
//  }
//}

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct tracker_ios_app: App {
    private let db: Firestore    
    private let userRepository: UserRepository
    private let notificationRepository: NotificationRepository
    private let locationRepository: LocationRepository
    
    private let authenticationService: AuthenticationService
    private let userService: UserService
    private let preferenceService: PreferenceService
    private let notificationService: NotificationService
    private let locationService: LocationService
    private let weatherService: WeatherService
    
    private let sharedViewModel: SharedViewModel
    private let userViewModel: UserViewModel
    private let notificationViewModel: NotificationViewModel
    private let locationViewModel: LocationViewModel
    
    init() {
        print("initing app")
        FirebaseApp.configure()
        
        self.db = Firestore.firestore()
        self.userRepository = UserRepository(db: db)
        self.notificationRepository = NotificationRepository(db: db)
        self.locationRepository = LocationRepository(db: db)
        
        self.preferenceService = PreferenceService()
        self.notificationService = NotificationService(notificationRepository: notificationRepository)
        self.authenticationService = AuthenticationService(preferenceService: preferenceService, notificationService: notificationService, userRepository: userRepository, notificationRepository: notificationRepository)
        self.userService = UserService(userRepository: userRepository, authenticationService: authenticationService, notificationService: notificationService)
        self.locationService = LocationService(locationRepository: locationRepository, userService: userService)
        self.weatherService = WeatherService()
        
        self.sharedViewModel = SharedViewModel()
        self.userViewModel = UserViewModel(authenticationService: authenticationService, preferenceService: preferenceService, userService: userService, locationService: locationService)
        self.notificationViewModel = NotificationViewModel(userService: userService, notificationService: notificationService, authenticationService: authenticationService)
        self.locationViewModel = LocationViewModel(locationService: locationService, weatherService: weatherService)
        
        authenticationService.autoSignInIfEnabled()
    }
    
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userViewModel).environmentObject(notificationViewModel)
                .environmentObject(locationViewModel)
                .environmentObject(sharedViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
