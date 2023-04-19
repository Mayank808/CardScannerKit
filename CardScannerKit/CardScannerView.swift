//
//  CardScannerView.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI

@ViewBuilder var defaultCardOverlay: some View {
    CardOutlineOverlay()
}

@ViewBuilder var defaultPhotoButton: some View {
    DefaultPhotoButtonView()
}

public struct CardScannerView<CardOverlay: View, ButtonContent: View>: View {
    @State private var frameHandler: CardFrameHandler = CardFrameHandler()
    @Binding var capturedImage: UIImage?
    @ViewBuilder let cardOverlay: CardOverlay
    @ViewBuilder let photoButton: ButtonContent
    
    init(
        capturedImage: Binding<UIImage?>,
        @ViewBuilder cardOverlay: () -> CardOverlay = { defaultCardOverlay as! CardOverlay },
        @ViewBuilder imageButton: () -> ButtonContent = { defaultPhotoButton as! ButtonContent }
    ) {
        self._capturedImage = capturedImage
        self.cardOverlay = cardOverlay()
        self.photoButton = imageButton()
    }
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                CardScannerViewRepresentable(camerService: $frameHandler)
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
    
    init(@ViewBuilder cardOverlay: () -> CardOverlay, capturedImage: Binding<UIImage?>) {
        self.init(
            capturedImage: capturedImage,
            cardOverlay: cardOverlay,
            imageButton: { defaultPhotoButton as! ButtonContent }
        )
    }
}

extension CardScannerView where CardOverlay == CardOutlineOverlay {
    
    init(capturedImage: Binding<UIImage?>, @ViewBuilder imageButton: () -> ButtonContent) {
        self.init(
            capturedImage: capturedImage,
            cardOverlay: { defaultCardOverlay as! CardOverlay },
            imageButton: imageButton
        )
    }
}

extension CardScannerView where CardOverlay == CardOutlineOverlay, ButtonContent == DefaultPhotoButtonView {
    
    init(capturedImage: Binding<UIImage?>) {
        self.init(
            capturedImage: capturedImage,
            cardOverlay: { defaultCardOverlay as! CardOverlay },
            imageButton: { defaultPhotoButton as! ButtonContent }
        )
    }
}


struct CardScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CardScannerView(capturedImage: .constant(nil))
            .ignoresSafeArea()
    }
}
