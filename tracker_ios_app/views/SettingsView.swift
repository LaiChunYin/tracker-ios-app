//
//  SettingsView.swift
//  tracker_ios_app
//
//  Created by macbook on 2/3/2024.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var nickName: String = ""
    @State private var avatarItem: PhotosPickerItem?
//    @State private var avatarImage: Image?
    @State private var avatarImage: UIImage?
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UpdateProfileError>? = nil
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the ratio by which to scale the image
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // Resize the image
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
        
    var body: some View {
        VStack {
            VStack {
//                if let img = avatarImage {
                if let img = avatarImage != nil ? resizeImage(image: avatarImage!, targetSize: CGSize(width: 500, height: 500)) : nil {
//                    Image(uiImage: img)
//                        .resizable()
//                        .scaledToFit()
                    
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 50)
                        .clipShape(Ellipse())
                        .overlay(Ellipse().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 5)
                    
                    Button {
                        avatarImage = nil
                    } label: {
                        Text("Remove Image")
                    }
                }
                else {
                    Image(systemName: "person.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                
                PhotosPicker("Upload Profile Picture", selection: $avatarItem, matching: .images)
                .onChange(of: avatarItem) {
                    Task {
                        guard let selectedPhotoItem = avatarItem else {
                            return
                        }

                        // Request the image data for the selected item.
                        let imageDataResult = try? await selectedPhotoItem.loadTransferable(type: Data.self)

                        if let imageData = imageDataResult, let image = UIImage(data: imageData) {
                            avatarImage = image
                        }
                    }
                }
            }
            
            HStack {
                Text("Nick Name:")
                TextField("Enter your Nick Name", text: $nickName)
            }
            
            Button {
                Task {
                    do {
                        // compress the image to low quality, a firestore document cannot exceed 1 Mb

                        let imgData = avatarImage != nil ? resizeImage(image: avatarImage!, targetSize: CGSize(width: 500, height: 500) ).jpegData(compressionQuality: 0) : nil
                        print("image size after \(imgData?.count) bytes")
                        
                        
                        try await userViewModel.updateProfile(userId: userViewModel.currentUser!.identifier, nickName: nickName, imageData: imgData)
                        
                        sentResult = .success(())
                        showAlert.toggle()
                    }
                    catch let error as UpdateProfileError {
                        sentResult = .failure(error)
                        showAlert.toggle()
                    }
                    catch let error {
                        print("error in updating profile \(error)")
                        sentResult = .failure(.unknown)
                        showAlert.toggle()
                    }
                }
            } label: {
                Text("Update User Settings")
            }
            .alert(isPresented: $showAlert) {
                switch sentResult {
                case .success:
                    return Alert(title: Text("Update Successful"), message: Text("Nick Name and Profile pic have been updated."))
                case .none:
                    return Alert(title: Text("Unknown"), message: Text("Unknown"))
                case .failure(let error):
                    let errMsg: String
                    switch error {
                    case .imageTooLarge:
                        errMsg = "Image too large"
                    case .emptyNickName:
                        errMsg = "Nick Name can not be empty."
                    case .databaseError:
                        errMsg = "There is a problem in the database"
                    default:
                        errMsg = "Unknown error"
                    }
                
                    return Alert(title: Text("Update Failed"), message: Text(errMsg))
                }
            }
        }
        .onAppear() {
            print("setting \(self.userViewModel.currentUser?.userData?.nickName ?? "nothing")")
            self.nickName = self.userViewModel.currentUser?.userData?.nickName ?? ""
            
            guard let imgData = Data(base64Encoded: self.userViewModel.currentUser?.userData?.profilePic ?? "") else {
                print("Error decoding Base64 string to Data")
                return
            }
            
            // Create UIImage from Data
            self.avatarImage = UIImage(data: imgData)
        }
    }
}

//#Preview {
//    SettingsView()
//}
