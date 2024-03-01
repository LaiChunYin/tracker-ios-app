//
//  LoginView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var viewSelection: Int? = nil
    @State private var loginError: LoginError? = nil
    
    var body: some View {
//        NavigationStack {
        NavigationStack {
            VStack(alignment: .center){
                NavigationLink(destination: SignUpView().environmentObject(userViewModel), tag: 1, selection: $viewSelection){}
                
                Text("User Name")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.orange)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                    .padding()
                
                Text("Password")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.orange)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                    .padding()
                    .padding(.bottom, 20)
                
                HStack {
                    Button{
                        rememberMe.toggle()
                    } label: {
                        Image(systemName: rememberMe ? "checkmark.square" : "square")
                            .foregroundColor(rememberMe ? .blue : .gray)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("Remember Me")
                }
                
                HStack {
                    Button {
                        Task {
                            do {
                                try await userViewModel.login(email: email, password: password, rememberMe: rememberMe)
                            }
                            catch let error as LoginError {
                                print("having error \(error)")
                                loginError = error
                            }
                            catch let error {
                                print("unknown error \(error)")
                                loginError = .unknown
                            }
                        }
                    } label: {
                        Text("Login")
                            .foregroundStyle(.white)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .fontWeight(.semibold)
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                    .alert(item: $loginError){ error in
                        let errMsg: String
                        switch error {
                        case .emptyUsernameOrPwd:
                            errMsg = "Please enter both username and password."
                        case .invalidUser, .wrongPwd:
                            errMsg = "Invalid username or password."
                        default:
                            errMsg = "Unknowm error"
                        }
                        return Alert(title: Text("Login Failed"), message: Text(errMsg))
                    }
                    
                    Spacer()
                    
                    Button {
                        print("sign up clicked")
                        viewSelection = 1
                    } label: {
                        Text("Sign up")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                    .tint(.indigo)
                    .buttonStyle(.borderedProminent)
                }
            }
            
        }
    }
}

//#Preview {
//    LoginView().environmentObject(UserViewModel())
//}
