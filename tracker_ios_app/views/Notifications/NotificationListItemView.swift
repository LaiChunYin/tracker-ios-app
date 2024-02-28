//
//  NotificationListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import SwiftUI

struct NotificationListItemView: View {
    var notification: Notification
    
    var body: some View {
        HStack {
            if !notification.read {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
            }
            
            VStack {
                Text("\(notification.title)")
                Text("\(notification.content)")
            }
        }
    }
}

#Preview {
    NotificationListItemView(notification: Notification())
}
