import Foundation
import SwiftUI

// Success callback types
public typealias CameraSuccessCallback = (_ image: Image?, _ videoURL: URL?) -> Void
public typealias GallerySuccessCallback = (_ media: Media) -> Void
public typealias MicSuccessCallback = (_ image: Image, _ videoURL: String) -> Void
public typealias LocationSuccessCallback = (_ image: Image, _ videoURL: String) -> Void
