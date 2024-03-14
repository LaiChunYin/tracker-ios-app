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
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var nickName: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UpdateProfileError>? = nil
    @State private var trackingFrequency: Double = 5
    @State private var geofenceRadius: Double = 100
    @State private var maxTimeDiffBetween2Points: Double = 60
    @State private var locationUploadTimeInterval: Int = 10
    
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
        GeometryReader{ geo in
            VStack {
                VStack {
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                    
                        
                        VStack{
                            if let img = avatarImage != nil ? resizeImage(image: avatarImage!, targetSize: CGSize(width: 500, height: 500)) : nil {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 5)
                                
                                Button {
                                    avatarImage = nil
                                } label: {
                                    Text("Remove Image")
                                }
                            }else{
                                Image(systemName: "person.circle")
                                     .foregroundColor(.gray)
                                     .font(.system(size: 120))
                                     .padding(.top)
                            }
                        }
                        .frame(width: geo.size.width/3)
                        
                        }
                        .frame(width: geo.size.width, height: geo.size.height/3)
                    
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
                
                HStack(alignment: .center) {
                     Image(systemName: "person")
                           .foregroundColor(.gray)
                     Text("Nick Name:")
                     Spacer()
                     TextField("Enter your Nick Name", text: $nickName)
                 }
                 .padding([.horizontal, .top])
                
                VStack {
                    
                    Text("Geofence Radius: \(String(format: "%.2f",geofenceRadius)) meters")
                    
                    Slider(value: $geofenceRadius, in: 50...10000, step: 1) {
                    } minimumValueLabel: {
                        Text("50")
                    } maximumValueLabel: {
                        Text("10000")
                    }.onChange(of: geofenceRadius) {
                        print("updating geofence radius to \(geofenceRadius)")
                    }
                }
                
                VStack {
                    
                    Text("Draw new path if disconnected for more than \(String(format: "%.0f" ,maxTimeDiffBetween2Points)) seconds")
                    
                    Slider(value: $maxTimeDiffBetween2Points, in: 1...3600, step: 1) {
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("3600")
                    }.onChange(of: maxTimeDiffBetween2Points) {
                        print("updating maxTimeDiffBetween2Points to \(maxTimeDiffBetween2Points)")
                    }
                }
                
                VStack {
                    
                    Text("Upload location every \(locationUploadTimeInterval) seconds")
                    
                    Slider(value: Binding(
                        get: { Double(locationUploadTimeInterval) },
                        set: { locationUploadTimeInterval = Int($0) })
                        , in: 1...1800, step: 1) {
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("1800")
                    }.onChange(of: locationUploadTimeInterval) {
                        print("updating locationUploadTimeInterval to \(locationUploadTimeInterval)")
                    }
                }
                
                
                Button {
                    Task {
                        do {
                            print("saving geofence radius \(geofenceRadius)")
                            locationViewModel.updateGeofenceRadius(radius: geofenceRadius)
                            locationViewModel.updateMaxTimeDiffBetween2Points(timeDiff: maxTimeDiffBetween2Points)
                            locationViewModel.updateLocationUploadTimeInterval(userId: userViewModel.currentUser!.identifier, interval: locationUploadTimeInterval)
                            
                            // compress the image to low quality, a firestore document cannot exceed 1 Mb
                            let imgData = avatarImage != nil ? resizeImage(image: avatarImage!, targetSize: CGSize(width: 500, height: 500) ).jpegData(compressionQuality: 0) : nil
                            print("image size after \(imgData?.count) bytes")
                            
                            
                            try await userViewModel.updateProfile(userId: userViewModel.currentUser!.identifier, nickName: nickName.trimmingCharacters(in: .whitespacesAndNewlines), imageData: imgData)
                            
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
                    Text("Update")
                }
                .alert(isPresented: $showAlert) {
                    switch sentResult {
                    case .success:
                        return Alert(title: Text("Update Successful"), message: Text("Nick Name, Profile pic and other settings have been updated."))
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
                .buttonStyle(.borderedProminent)
                .padding(.top)
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
                
                self.geofenceRadius = locationViewModel.geofenceRadius
                self.maxTimeDiffBetween2Points = locationViewModel.maxTimeDiffBetween2Points
                self.locationUploadTimeInterval = locationViewModel.locationUploadTimeInterval
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}
