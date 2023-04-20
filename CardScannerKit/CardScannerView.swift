//
//  CardScannerView.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

@ViewBuilder public var defaultCardOverlay: some View {
    CardOutlineOverlay()
}

@ViewBuilder public var defaultPhotoButton: some View {
    DefaultPhotoButtonView()
}

public struct CardScannerView<CardOverlay: View, ButtonContent: View>: View {
    @State private var frameHandler: CardFrameHandler = CardFrameHandler()
    @Binding var capturedImage: UIImage?
    @ViewBuilder let cardOverlay: CardOverlay
    @ViewBuilder let photoButton: ButtonContent
    var scanDelay: Double
    
    public init(
        capturedImage: Binding<UIImage?>,
        scanDelay: Double = 3.0,
        @ViewBuilder cardOverlay: () -> CardOverlay = { defaultCardOverlay as! CardOverlay },
        @ViewBuilder imageButton: () -> ButtonContent = { defaultPhotoButton as! ButtonContent }
    ) {
        self._capturedImage = capturedImage
        self.cardOverlay = cardOverlay()
        self.photoButton = imageButton()
        self.scanDelay = scanDelay
    }
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                CardScannerViewRepresentable(camerService: $frameHandler, scanDelay: scanDelay)
            }
            .zIndex(0)
            .frame(maxWidth: .infinity)
            
            cardOverlay
                .zIndex(1)
            
            VStack {
                Spacer()
                Button(action: {
                    frameHandler.captureImage()
                }, label: {
                    photoButton
                })
                .padding(.bottom)
            }.zIndex(2)
        }
        .onReceive(frameHandler.$cardImage) { image in
            if let cardImage = image {
                self.capturedImage = cardImage
                dismiss()
            }
        }
    }
}

// ⭐️ conditional extensions for convenience inits

extension CardScannerView where ButtonContent == DefaultPhotoButtonView {
    
    public init(capturedImage: Binding<UIImage?>, scanDelay: Double = 3.0, @ViewBuilder cardOverlay: () -> CardOverlay) {
        self.init(
            capturedImage: capturedImage,
            scanDelay: scanDelay,
            cardOverlay: cardOverlay,
            imageButton: { defaultPhotoButton as! ButtonContent }
        )
    }
}

extension CardScannerView where CardOverlay == CardOutlineOverlay {
    
    public init(capturedImage: Binding<UIImage?>, scanDelay: Double = 3.0, @ViewBuilder imageButton: () -> ButtonContent) {
        self.init(
            capturedImage: capturedImage,
            scanDelay: scanDelay,
            cardOverlay: { defaultCardOverlay as! CardOverlay },
            imageButton: imageButton
        )
    }
}

extension CardScannerView where CardOverlay == CardOutlineOverlay, ButtonContent == DefaultPhotoButtonView {
    
    public init(capturedImage: Binding<UIImage?>, scanDelay: Double = 3.0) {
        self.init(
            capturedImage: capturedImage,
            scanDelay: scanDelay,
            cardOverlay: { defaultCardOverlay as! CardOverlay },
            imageButton: { defaultPhotoButton as! ButtonContent }
        )
    }
}
//
//struct CardScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardScannerView(capturedImage: .constant(nil))
//            .ignoresSafeArea()
//    }
//}
