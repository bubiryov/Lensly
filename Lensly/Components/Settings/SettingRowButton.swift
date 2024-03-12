//
//  SettingRowButton.swift
//  Lensly
//
//  Created by Egor Bubiryov on 09.03.2024.
//

import SwiftUI

struct SettingRowButton: View {
    
    let labelContent: LabelContent
    let isSelected: Bool
    let action: () -> Void

    enum LabelContent {
        case text(String)
        case image(String)
    }

    var body: some View {
        Button {
            action()
        } label: {
            buttonLabelView()
                .foregroundColor(isSelected ? .black.opacity(0.5) : .white.opacity(0.5))
                .font(.nunito(.extraBold, size: 10))
                .frame(maxWidth: 45, maxHeight: 45)
                .background(isSelected ? .accentYellow : .black.opacity(0.4))
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .shouldBeRotatable()
    }
}

extension SettingRowButton {
    @ViewBuilder
    func buttonLabelView() -> some View {
        switch labelContent {
        case .text(let text):
            Text(text)
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 15)
        }
    }
}
