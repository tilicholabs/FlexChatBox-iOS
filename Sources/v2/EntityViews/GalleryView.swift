import SwiftUI
import PhotosUI

// MARK: - GalleryView
public struct GalleryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var imagePicker = ImagePicker()
    public var cameraSuccessCallback: GallerySuccessCallback
    
    public var body: some View {
        PhotosPicker(selection: $imagePicker.imageSelections,
                     maxSelectionCount: 30,
                     matching: .any(of: [.images, .videos]),
                     photoLibrary: .shared()) {
            Image(systemName: FlexHelper.galleryButtonImageName)
                .flexIconFrame()
                .padding()
                .foregroundColor(Color.white)
                .flexBackground()
                .flexIconCornerRadius()
        }
                     .onAppear {
                         imagePicker.onCompletion = {
                             cameraSuccessCallback($0)
                         }
                     }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView { _ in }
    }
}
