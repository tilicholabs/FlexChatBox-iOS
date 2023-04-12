//
//  FlexType.swift
//
//
//  Created by Aditya Kumar Bodapati on 01/03/23.
//

import SwiftUI

public enum FlexType: String, CaseIterable {
    case camera
    case gallery
    case mic
    case location
    case contacts
    case files
    case custom
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

public enum FlexOutput {
    case text(String)
    case camera(Image)
    case gallery(Media)
    case mic(URL)
    case custom(String)
    case location(Location)
    case contacts([Contact])
    case files([URL])
    case video(URL)
}
