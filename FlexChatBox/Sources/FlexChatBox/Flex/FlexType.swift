//
//  File.swift
//
//
//  Created by Aditya Kumar Bodapati on 01/03/23.
//

import UIKit
import SwiftUI
import MapKit

public enum FlexType {
    case camera
    case gallery
    case mic
    case custom
    case location
    case contacts
    case files
}

public extension FlexType {
    var icon: String {
        switch self {
        case .camera:
            return FlexHelper.cameraButtonImageName
        case .gallery:
            return FlexHelper.galleryButtonImageName
        case .mic:
            return FlexHelper.micButtonImageName
        case .custom:
            return FlexHelper.customButtonImageName
        case .location:
            return FlexHelper.locationButtonImageName
        case .contacts:
            return FlexHelper.contactsButtonImageName
        case .files:
            return FlexHelper.filesButtonImageName
        }
    }
}

public typealias MapView = Map<_DefaultAnnotatedMapContent<[Location]>>
public enum FlexOutput {
    case camera(Image)
    case gallery(Media)
    case mic(URL)
    case custom(String)
    case location(MapView)
    case contacts([Contact])
    case files([URL])
    case video(URL)
}
