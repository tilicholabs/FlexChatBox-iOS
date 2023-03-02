//
//  File.swift
//
//
//  Created by Aditya Kumar Bodapati on 01/03/23.
//

import UIKit
import SwiftUI

public enum FlexType {
    case camera
    case gallery
    case mic
    case custom
}

extension FlexType {
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
        }
    }
}


public enum FlexOutput {
    case camera(Image)
    case gallery(Media)
    case mic(URL)
    case custom(String)
}
