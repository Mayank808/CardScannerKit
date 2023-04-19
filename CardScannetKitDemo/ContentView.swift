//
//  ContentView.swift
//  CardScannetKitDemo
//
//  Created by Mayank Mehra on 2023-04-19.
//

import SwiftUI
import CardScannerKit

struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var showSheet: Bool = false
    @State private var showUnhappyFlow: Bool = true
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .border(Color.pink)
                    .clipped()
            }
            if !showUnhappyFlow {
                Button("Take Photo") {
                    showSheet.toggle()
                }
            } else {
                VStack(spacing: 15) {
                    Text("Error Occured ⛈️")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    Text("Error: Please allow app access to camera to use these features")
                        .font(.subheadline)
                        .padding([.leading, .trailing])
                }
                .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            ImagePermissionHandler.shared.checkPermissions { granted in
                if !granted {
                    print("Show unhappy flow")
                    showUnhappyFlow.toggle()
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            // default
            CardScannerView(capturedImage: $capturedImage)
            
            // Specify specific components yourself
//            CardScannerView(capturedImage: $capturedImage, imageButton: {
//                Image(systemName: "photo.on.rectangle.angled")
//                    .padding()
//                    .background(Color.pink)
//                    .foregroundColor(.white)
//                    .clipShape(Circle())
//            })
            
            // Specify both components yourself
//            CardScannerView(capturedImage: $capturedImage, imageButton: {
//                Image(systemName: "photo.on.rectangle.angled")
//                    .padding()
//                    .background(Color.pink)
//                    .foregroundColor(.white)
//                    .clipShape(Circle())
//            }, cardOverlay: {
//                // Custom Overlay Here
//            })
//            .ignoresSafeArea()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
