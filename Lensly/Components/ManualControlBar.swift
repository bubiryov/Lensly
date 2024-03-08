//
//  ManualControlBar.swift
//  Lensly
//
//  Created by Egor Bubiryov on 05.03.2024.
//

import SwiftUI

struct ManualControlBar: View {
    
    @Namespace private var animationNamespace
    @Binding var selectedManualOption: CameraOption
    let manualOptions: [(option: CameraOption, value: Any, isLocked: Bool)]
    
    var body: some View {
        HStack {
            ForEach(manualOptions.indices, id: \.self) { index in
                ZStack {
                    
                    selectionRectangleLayer(index: index)
                    
                    manualControlOptionButton(
                        option: manualOptions[index].option,
                        value: manualOptions[index].value
                    )
                    .shouldBeRotatable()
                    .disabled(manualOptions[index].isLocked)
                    .opacity(manualOptions[index].isLocked ? 0.5 : 1)
                }
                .padding(.vertical, 4)
                .animation(.interactiveSpring, value: selectedManualOption)
                
                if index != manualOptions.count - 1 {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .font(.nunito(.medium, size: 13))
        .padding(.horizontal, 6)
        .background(.white.opacity(0.15))
        .cornerRadius(20)
    }
}

#Preview {
    let manualOptions: [(option: CameraOption, value: Any, isLocked: Bool)] = [
        (.exposureValue, 0, false),
        (.iso, 0, false),
        (.shutterSpeed, 0, false),
        (.focus, 0, true),
        (.whiteBalance, 0, false)
    ]
    
    return ManualControlBar(
        selectedManualOption: .constant(.exposureValue),
        manualOptions: manualOptions
    )
    .padding(.horizontal)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

extension ManualControlBar {
    
    @ViewBuilder
    func selectionRectangleLayer(index: Int) -> some View {
        if selectedManualOption == manualOptions[index].option {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(.black)
                .matchedGeometryEffect(id: "selectedTab", in: animationNamespace)
        }
    }
    
    func manualControlOptionButton(option: CameraOption, value: Any) -> some View {
        Button {
            selectedManualOption = option
        } label: {
            controlButtonView(title: option.rawValue, value: value)
        }
        .buttonStyle(.plain)
    }
    
    func controlButtonView(title: String, value: Any) -> some View {
        VStack {
            Text(title)
                .foregroundColor(title == selectedManualOption.rawValue ? .accentYellow : .white)
                .font(.nunito(.bold, size: 14))
            
            HStack {
                if let value = value as? Int {
                    Text("1/\(value)")
                } else if let value = value as? Float {
                    Text("\(value.formattedString())")
                }
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}
