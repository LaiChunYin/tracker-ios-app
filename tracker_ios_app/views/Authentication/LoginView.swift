//
//  LoginView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = "Test@gmail.com"
    @State private var password: String = "11111111"
    @State private var rememberMe: Bool = false
    @State private var viewSelection: Int? = nil
    @State private var loginError: LoginError? = nil
    
    var body: some View {
        
        GeometryReader{ geo in
            
            NavigationStack {
                
                ZStack{
                    
                    Image(.loginBack)
                        .resizable()
                        .blur(radius: 5)
                        .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .edgesIgnoringSafeArea(.all)
                                    .opacity(1)
                                    .blur(radius: 1)
                                    .clipShape(.rect(cornerRadius: 15))
                                        
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .opacity(0.8)
                
                VStack(alignment: .center){
                    
                    NavigationLink(destination: SignUpView().environmentObject(userViewModel), tag: 1, selection: $viewSelection){}
                    
                    usernameAndPasswordView(email: $email, password: $password)
                    
                    rememberMeView(rememberMe: $rememberMe)
                    
                    HStack {
                        loginButton(userViewModel: _userViewModel, email: $email, password: $password, rememberMe: $rememberMe)
                        
                        Spacer()
                        
                        signUpButton(viewSelection: $viewSelection)
                    }
                        .padding()
                    }
                }
            }    
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    
    struct usernameAndPasswordView: View {
        @Binding var email: String
        @Binding var password: String
        
        var body: some View {
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
        }
    }
    
    struct rememberMeView: View{
        @Binding var rememberMe: Bool
        
        var body: some View{
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
        }
    }
    
    struct loginButton: View{
        
        @EnvironmentObject var userViewModel: UserViewModel
        @Binding var email: String
        @Binding var password: String
        @Binding var rememberMe: Bool
        
        var body: some View{
            Button {
                userViewModel.login(email: email, password: password, rememberMe: rememberMe)
            } label: {
                Text("Login")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .tint(.green)
            .buttonStyle(.borderedProminent)
        }
    }
    
    struct signUpButton: View{
        @Binding var viewSelection: Int? // might cause error
        
        var body: some View{
            Button {
                print("sign up clicked")
                viewSelection = 1
            } label: {
                Text("Sign up")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .font(.title2)
            }
            .tint(.indigo)
            .buttonStyle(.borderedProminent)
        }
    }
}
