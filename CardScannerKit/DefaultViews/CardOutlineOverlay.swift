//
//  CardOutlineOverlay.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

struct CardOutlineOverlay: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        GeometryReader { dimension in
            ZStack {
                Rectangle().foregroundColor(.black.opacity(0.05))
                VStack(alignment: .center) {
                    Rectangle()
                        .frame(width: dimension.size.width * 0.85, height: 210, alignment: .center)
                        .blendMode(.destinationOut)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.red, lineWidth: 4)
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
