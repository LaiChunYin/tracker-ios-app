//
//  FriendListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FriendListItemView: View {
    var user: String
    
    init(user: String) {
        self.user = user
    }
    
    var body: some View {
        Text("\(user)")
    }
}

//#Preview {
//    FriendListItemView()
//}
