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
    @State private var nickName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var signUpError: SignUpError? = nil
    
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
            
            TextField("Enter your Nick Name", text: $nickName)
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
                Task {
                    do {
                        try await userViewModel.signUp(email: email, nickName: nickName, password: password, confirmPassword: confirmPassword)
                    }
                    catch let error as SignUpError {
                        signUpError = error
                    }
                    catch {
                        print("unknown error")
                        signUpError = .unknown
                    }
                }
            } label: {
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .alert(item: $signUpError) { error in
                let errMsg: String
                switch error {
                    case .alreadyExist:
                        errMsg = "The username is already used."
                    case .weakPassword:
                        errMsg = "Password is too weak."
                    case .confirmPwdNotMatch:
                        errMsg = "Password does not match with the confirm password."
                    case .emptyInputs:
                        errMsg = "All input fields are mandatory."
                    default:
                        errMsg = "Unknown error"
                }
                return Alert(title: Text("Sign Up Failed"), message: Text(errMsg))
            }

        }
    }
}

//#Preview {
////    SignUpView().environmentObject(UserViewModel())
//    SignUpView().environmentObject(UserViewModel(authenticationService: AuthenticationService(), preferenceService: PreferenceService(), userRepository: UserRepository(db: Firestore.firestore())))
//}
