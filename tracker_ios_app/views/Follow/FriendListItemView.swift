//
//  FriendListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import PhotosUI

struct FriendListItemView: View {
    private var userId: String
    var icon: String = ""
    private var userItemSummary: UserItemSummary
    private var avatarImage: UIImage?
    private var dateFormatter: DateFormatter
    
//    init(userId: String, userItemSummaryDict: [String: Any], icon: String) {
    init(userId: String, userItemSummary: UserItemSummary, icon: String) {
//        do {
            self.userId = userId
            self.userItemSummary = userItemSummary
            self.icon = icon
            
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            
            guard let imgData = Data(base64Encoded: userItemSummary.profilePic) else {
                print("Error decoding Base64 string to Data, user \(userId)")
                return
            }
            
            // Create UIImage from Data
            self.avatarImage = UIImage(data: imgData)
//        }
//        catch {
//            print("cannot decode userItemSummary")
//        }
    }
    
    var body: some View {
        VStack{
            
            HStack {
                HStack {
                    if let img = avatarImage {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                            .shadow(radius: 5)
                    }
                    else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            
                    Text("\(userItemSummary.nickName)")
                }
                Spacer()
                
                if(icon.isEmpty){
                    
                    Button{
                        // write code to follow back
                    }label: {
                        Text("Follow")
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                }else{
                    Image(systemName: icon)
                          .font(.title)
                          .foregroundColor(.green)
                }
            }
            .padding(.vertical, 5)
            
            HStack {
                Text("id: \(self.userId)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("accepted: \(dateFormatter.string(from: userItemSummary.connectionTime))")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

//#Preview {
//    FriendListItemView()
//}
