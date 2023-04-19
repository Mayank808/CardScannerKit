//
//  CardScannerViewRepresentable.swift
//  CardScannerKit
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI
import AVFoundation
import Vision


struct CardScannerViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var camerService: CardFrameHandler
    let scanDelay: Double
    
    func makeUIViewController(context: Context) -> UIViewController {
        camerService.startCamera(scanDelay: scanDelay)
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(camerService.previewLayer)
        
        camerService.previewLayer.frame = viewController.view.bounds
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

//struct CardScannerViewRepresentableContainer_Previews: View {
//    @State private var frameHandler = CardFrameHandler()
//    
//    var body: some View {
//        CardScannerViewRepresentable(camerService: $frameHandler)
//    }
//}
//
//struct CardScannerViewRepresentable_Previews : PreviewProvider {
//    static var previews: some View {
//        CardScannerViewRepresentableContainer_Previews()
//    }
//}
