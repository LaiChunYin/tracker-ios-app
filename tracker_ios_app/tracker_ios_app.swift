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
//    let db = Firestore.firestore()
//    let userRepository = UserRepository(db: db)
//    
//    let authenticationService = AuthenticationService(userRepository: userRepository)
//    let preferenceService = PreferenceService()
//    let notificationService = NotificationService()
//    let weatherService = WeatherService()
//   
//    let userViewModel = UserViewModel(authenticationService: authenticationService, preferenceService: preferenceService, userRepository: userRepository)
//    let NotificationViewModel = NotificationViewModel()
    
    private let db: Firestore
//    private let userRepository: UserRepository
    
//    private let authenticationService: AuthenticationService
    private let preferenceService: PreferenceService
//    private let notificationService: NotificationService
//    private let weatherService: WeatherService
   
    private let userViewModel: UserViewModel
    private let notificationViewModel: NotificationViewModel
    
    init() {
        FirebaseApp.configure()
        
        self.db = Firestore.firestore()
//        self.userRepository = UserRepository(db: db)
        
//        self.authenticationService = AuthenticationService(userRepository: userRepository)
        self.preferenceService = PreferenceService()
//        self.notificationService = NotificationService()
//        self.weatherService = WeatherService()
       
//        self.userViewModel = UserViewModel(authenticationService: authenticationService, preferenceService: preferenceService, userRepository: userRepository)
        self.userViewModel = UserViewModel(db: db, preferenceService: preferenceService)
        self.notificationViewModel = NotificationViewModel(db: db, userViewModel: userViewModel)
    }
    
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userViewModel).environmentObject(notificationViewModel)
        }
        .onChange(of: scenePhase) { currentPhase in
            switch scenePhase {
                case .active:
                    print("active app")
//                    guard preferenceService.isRememberLoginStatus else {
//                        print("require to login again")
//                        userViewModel.logout()
//                        return
//                    }
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
