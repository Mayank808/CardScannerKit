# CardScannerKit

Uses Vision Kit and AVFoundations to build a ready to use document/card scanner view. Use the CardScannerView() with the ability to customize the button and card overlay of the view ontop of the default functionality. You also have access to ImagePermissionHandler() which will allow you to ask the user for permission to utilize their devices camera. Insure that you have defined a Privacy - Camera Usage Description in your apps Info.plst before using the card scanner.

Once the CardScannerView appears it will wait a few seconds to give the user time to stabalize the card/document in the view and will then begin scanning for cards in the camera frames. If a card is found then a Image will automatically be take and cropped around the card detected in the frame.
At anytime the user also has the ability to simply take a photo themselves instead of having to wait for the scan by pressing the action button provided in the view. If the user clicks the button the image will be take and may be cropped if a card is detected within the frame.

Please refer to the video below for a basic implementation using the CardScannerView in a bottomsheet. Code is provided in the CardScannerKitDemo folder.

![CardScannerDemo](https://github.com/Mayank808/CardScannerKit/assets/70068077/be793591-66e7-454d-8d2a-e4106b178394)

## Example Code

```swift
import SwiftUI
import CardScannerKit

struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var showSheet: Bool = false

    var body: some View {
        VStack {
            if let image = capturedImage {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .border(Color.pink)
                        .clipped()
                }
            }
            Button(action: {
                showSheet.toggle()
            }, label: {
                HStack {
                    Text("Take Photo")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
            })
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
            CardScannerView(capturedImage: $capturedImage, autoCropImage: true)
            
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
