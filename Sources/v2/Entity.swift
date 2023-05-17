import Foundation
import SwiftUI

/// How about abstracting all the common propertites from `Entity` into an  Interface, so that we can extend it to define all the Entity typest?
/// Only issue with this implementation is we have to define as many Entity types as the FlexTypes.
/// Strategy pattern? Adapter pattern?
public struct Entity<Content> where Content: View {
    var type: FlexInputType
    @ViewBuilder var invocationContentView: Content
    
    public init(type: FlexInputType,
                @ViewBuilder _ invocationContentView: () -> Content) {
        self.type = type
        self.invocationContentView = invocationContentView()
    }
}

// Invocation callback types
typealias CameraInvocationCallback<T> = () -> T
typealias GalleryInvocationCallback<T> = () -> T
typealias MicInvocationCallback<T> = () -> T
typealias LocationInvocationCallback<T> = () -> T

// typealias FlexCameraEntity = Entity<.custom("snapCamera"), CustomInvocationCallback, CustomSuccessCallback>

typealias SnapCamInvocationCallback<T> = () -> T
// typealias SnapCamSuccessCallback = (rawImage: Image, processedImage: Image, exif: Exif, data: SnapData)

// SuccessCallback
public typealias FlexSuccessCallback = (any View) -> ()
