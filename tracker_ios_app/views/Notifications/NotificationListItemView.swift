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
        HStack() {
            if !notification.read {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
            }
            
            VStack(alignment: .leading) {
                Text("\(notification.title)")
                Text("\(notification.content)")
                    .font(Font(CTFont(.application, size: 15)))
                    .foregroundStyle(!notification.read ? .white : .gray)
            }
            .padding(.horizontal, !notification.read ? 0 : 20)
        }
    }
}

#Preview {
    NotificationListItemView(notification: Notification())
}
