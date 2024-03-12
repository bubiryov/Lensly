//
//  SettingsRow.swift
//  Lensly
//
//  Created by Egor Bubiryov on 09.03.2024.
//

import SwiftUI

struct SettingsRow<Content: View>: View {
    
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.nunito(.extraBold, size: 15))
                .foregroundColor(.accentYellow)
            
            Spacer()
            
            HStack(spacing: 10) {
                content
            }
        }
        .padding(.horizontal)
        .frame(height: 45)
    }
}
