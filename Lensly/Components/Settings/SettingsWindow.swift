//
//  SettingsWindow.swift
//  Lensly
//
//  Created by Egor Bubiryov on 09.03.2024.
//

import SwiftUI

struct SettingsWindow<Content: View>: View {
        
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                content
            }
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
        .background(.black.opacity(0.5))
        .cornerRadius(20)
    }
}


#Preview {
    SettingsWindow() {
        ForEach(0..<5) { _ in
            SettingsRow(title: "Some row title") {
                ForEach(0..<3) { _ in
                    SettingRowButton(labelContent: .text("Text"), isSelected: false) {
                        
                    }
                }
            }
        }
    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray)
}
