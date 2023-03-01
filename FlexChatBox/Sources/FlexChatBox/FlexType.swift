//
//  File.swift
//  
//
//  Created by Aditya Kumar Bodapati on 01/03/23.
//

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
