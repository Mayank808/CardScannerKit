//
//  CardOutlineOverlay.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

public struct CardOutlineOverlay: View {
    var widthPercentage: Double = 0.85
    @State var height: Double = 210
    @State var width: Double = 0
    @State private var orientation = UIDeviceOrientation.unknown
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    public var body: some View {
        GeometryReader { dimension in
            ZStack {
                Rectangle().foregroundColor(.black.opacity(0.05))
                VStack(alignment: .center) {
                    Rectangle()
                        .frame(width: width, height: height, alignment: .center)
                        .fixedSize()
                        .blendMode(.destinationOut)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.pink, lineWidth: 10)
                        )
                        .cornerRadius(12)
                }.frame(maxWidth: .infinity)
                    .padding(.top)
                    .onAppear {
                        self.width = dimension.size.width * widthPercentage
                    }
//                    .onAppear {
//                        if orientation.isLandscape {
//                            self.width = dimension.size.height * widthPercentage
//                        } else {
//                            self.width = dimension.size.width * widthPercentage
//                        }
//                    }
//                    .onRotate { newOrientation in
//                        orientation = newOrientation
//                    }
            }.compositingGroup()
        }
    }
}


struct CardOverlay_Previews: PreviewProvider {
    static var previews: some View {
        CardOutlineOverlay()
    }
}
