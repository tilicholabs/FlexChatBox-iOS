import Foundation
import SwiftUI

// Create views for each individual flexType
public class InvocationViewFactory {
    static func cameraInvocationCallback(_ successCallback: @escaping CameraSuccessCallback) -> AnyView {
        return CameraView(cameraSuccessCallback: successCallback)
            .eraseToAnyView()
    }
    
    static func galleryInvocationCallback(_ successCallback: @escaping GallerySuccessCallback) -> AnyView {
        return GalleryView(cameraSuccessCallback: successCallback)
            .eraseToAnyView()
    }
    
    static func microphoneInvocationCallback() -> AnyView {
        // Check for permissions
        // Launch microphone
        // Prepare output
        // Send output
        return PlaceholderView()
            .eraseToAnyView()
    }
}
