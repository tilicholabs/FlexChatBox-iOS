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
}

public extension FlexType {
    var icon: String {
        switch self {
        case .camera:
            return "camera"
        case .gallery:
            return "photo"
        case .mic:
            return "mic"
        case .custom:
            return "paperclip"
        case .location:
            return "location"
        case .contacts:
            return "person"
        }
    }
}


public enum FlexOutput {
    case camera(Image)
    case gallery(Media)
    case mic(URL)
    case custom(String)
    case location(Map<_DefaultAnnotatedMapContent<[Location]>>)
    case contacts([Contact])
}
