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
    
    private let authenticationService: AuthenticationService
    private let userService: UserService
    private let preferenceService: PreferenceService
    private let notificationService: NotificationService
//    private let weatherService: WeatherService
    
    private let userViewModel: UserViewModel
    private let notificationViewModel: NotificationViewModel
    
    init() {
        FirebaseApp.configure()
        
//        self.db = Firestore.firestore()
//        self.userRepository = UserRepository(db: db)
//        self.preferenceService = PreferenceService()
//        self.userViewModel = UserViewModel(db: db, preferenceService: preferenceService)
//        self.notificationViewModel = NotificationViewModel(db: db, userViewModel: userViewModel)
        
        self.db = Firestore.firestore()
        self.userRepository = UserRepository(db: db)
        self.notificationRepository = NotificationRepository(db: db)
        
        self.preferenceService = PreferenceService()
        self.notificationService = NotificationService(notificationRepository: notificationRepository)
        self.authenticationService = AuthenticationService(preferenceService: preferenceService, notificationService: notificationService, userRepository: userRepository, notificationRepository: notificationRepository)
        self.userService = UserService(userRepository: userRepository, authenticationService: authenticationService, notificationService: notificationService)
        
        self.userViewModel = UserViewModel(authenticationService: authenticationService, preferenceService: preferenceService, userService: userService)
        self.notificationViewModel = NotificationViewModel(userService: userService, notificationService: notificationService, authenticationService: authenticationService)
    }
    
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userViewModel).environmentObject(notificationViewModel)
                .onAppear{ // for debugging purposes
                    print("ios_app: \(userViewModel.currentUser)")
                }
        }
        .onChange(of: scenePhase) { currentPhase in
            switch scenePhase {
                case .active:
                    print("active app")
                default:
                    print("not active app")
                    guard preferenceService.isRememberLoginStatus else {
                        print("require to login again")
                        userViewModel.logout()
                        return
                    }
            }
        }
    }
}
