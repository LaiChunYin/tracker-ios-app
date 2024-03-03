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
        
        GeometryReader{ geo in
            
            VStack(alignment: .center, spacing: 10) {
                
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
                    
                    VStack{
                        Spacer()
                        Spacer()
                        
                        usernameAndPassword(email: $email, password: $password, confirmPassword: $confirmPassword)
                        
                        Spacer()
                        
                        createAccountButton(userViewModel: _userViewModel, email: $email, password: $password, confirmPassword: $confirmPassword)
                        
                        Spacer()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    struct usernameAndPassword: View {
        
        @Binding var email: String
        @Binding var password: String
        @Binding var confirmPassword: String
        
        
        var body: some View {
            Text("User Name")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
            
            Text("Password")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
            
            Text("Confirm Password")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            SecureField("Confirm your password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.orange)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                .padding()
        }
    }
    
    struct createAccountButton: View {
        @EnvironmentObject var userViewModel: UserViewModel
        @Binding var email: String
        @Binding var password: String
        @Binding var confirmPassword: String
        
        var body: some View {
            Button {
                userViewModel.createAccount(email: email, password: password, confirmPassword: confirmPassword)
            } label: {
                Text("Create Account")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .tint(.green)
            .buttonStyle(.borderedProminent)
        }
    }
}

//#Preview {
////    SignUpView().environmentObject(UserViewModel())
//    SignUpView().environmentObject(UserViewModel(authenticationService: AuthenticationService(), preferenceService: PreferenceService(), userRepository: UserRepository(db: Firestore.firestore())))
//}
