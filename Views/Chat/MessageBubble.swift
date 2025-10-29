//
//  Message.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isFromCurrentUser ? .white : .primary)
                .cornerRadius(16)
            
            if !isFromCurrentUser { Spacer() }
        }
    }
}
