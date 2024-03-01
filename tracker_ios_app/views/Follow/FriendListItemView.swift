//
//  FriendListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FriendListItemView: View {
    var user: String = ""
    var icon: String
    
    var body: some View {
        VStack{
            
            HStack {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text(user)
                }
                Spacer()
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.green)
            }
            .padding(.vertical, 5)
            
            HStack {
                Text("id: #12003")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("joined: 12-1-2024")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

//#Preview {
//    FriendListItemView()
//}
