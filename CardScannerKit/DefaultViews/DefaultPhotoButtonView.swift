//
//  DefaultPhotoButtonView.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

public struct DefaultPhotoButtonView: View {
    public var body: some View {
        Image(systemName: "circle")
            .font(.system(size: 72))
            .foregroundColor(.pink)
    }
}

struct DefaultPhotoButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultPhotoButtonView()
    }
}
