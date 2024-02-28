//
//  SignUpView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("User Name")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
            
            Text("Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
            
            Text("Confirm Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            SecureField("Confirm your password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
            
            Button {
                userViewModel.createAccount(email: email, password: password, confirmPassword: confirmPassword)
            } label: {
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(Color.green)
                    .cornerRadius(10)
            }

        }
    }
}

//#Preview {
////    SignUpView().environmentObject(UserViewModel())
//    SignUpView().environmentObject(UserViewModel(authenticationService: AuthenticationService(), preferenceService: PreferenceService(), userRepository: UserRepository(db: Firestore.firestore())))
//}
