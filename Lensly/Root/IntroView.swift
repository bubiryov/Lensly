//
//  IntroView.swift
//  Lensly
//
//  Created by Egor Bubiryov on 12.03.2024.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        IntroAnimation()
            .frame(width: 120, height: 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
    }
}

#Preview {
    IntroView()
}
