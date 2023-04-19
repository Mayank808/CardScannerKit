//
//  CardOutlineOverlay.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

public struct CardOutlineOverlay: View {
    let widthPercentage: Double
    let height: Double
    
    init(widthPercentage: Double = 0.85, height: Double = 210) {
        self.widthPercentage = widthPercentage
        self.height = height
    }
    
    public var body: some View {
        GeometryReader { dimension in
            ZStack {
                Rectangle().foregroundColor(.black.opacity(0.05))
                VStack(alignment: .center) {
                    Rectangle()
                        .frame(width: dimension.size.width * 0.85, height: height, alignment: .center)
                        .blendMode(.destinationOut)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.pink, lineWidth: 10)
                        )
                        .cornerRadius(12)
                }.frame(maxWidth: .infinity)
                    .padding(.top)
            }.compositingGroup()
        }
    }
}


struct CardOverlay_Previews: PreviewProvider {
    static var previews: some View {
        CardOutlineOverlay()
    }
}
