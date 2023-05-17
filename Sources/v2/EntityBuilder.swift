import Foundation
import SwiftUI

// Use builder design pattern or factory pattern to create each entity generically
// Made all the return types to confirm to AnyView just to fix an issue with the generic view creation
// https://betterprogramming.pub/a-mixed-bag-of-swiftui-11e018a280b7#:~:text=SwiftUI%20view%20builders.-,Wrapping%20in%20AnyView,-Wrapping%20in%20AnyView
public class EntityBuilder {
    public static func flexCameraEntity(_ successCallback: @escaping CameraSuccessCallback) -> Entity<AnyView> {
        return Entity<AnyView>(type: .camera) {
            InvocationViewFactory.cameraInvocationCallback(successCallback)
        }
    }
    
    public static func flexGalleryEntity(_ successCallback: @escaping GallerySuccessCallback) -> Entity<AnyView> {
        return Entity<AnyView>(type: FlexInputType.gallery) {
            InvocationViewFactory.galleryInvocationCallback(successCallback)
        }
    }
    
    public static func flexMicEntity() -> Entity<AnyView> {
        return Entity<AnyView>(type: FlexInputType.mic) {
            InvocationViewFactory.microphoneInvocationCallback()
        }
    }
    
    public static func flexCustomEntity<Content: View>(@ViewBuilder _ invocationContentView: () -> Content) -> Entity<AnyView> {
        return Entity<AnyView>(type: FlexInputType.custom) {
            invocationContentView()
                .eraseToAnyView()
        }
    }
}
